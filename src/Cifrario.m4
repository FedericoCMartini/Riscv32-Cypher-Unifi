.data
    myplaintext: .string "STUDENTE123"
    max_size: .byte 200
    mycypher: .string "DD"
    blocKey: .string "OLA"
    .align 2
    sostK: .byte -25
    arena_in_use: .byte 0
    default_str: .string "default"
    default_cypher: .string "ABCDE"
    accepted_cyphers: .string "ABCDE" #for the sanitizer to trunkate the cypher string at the first occurrence of a character not in this string
    
# project conventions:
# use of registers based on:
# https://cs61c.org/sp26/pdfs/discussions/disc05/disc05-pre-sols.pdf
#
# additionally:
# s0 holds stack frame size if defined

# stack management:
# subtract 8 from sp
# store ra into 4(sp)

# if saved registers are used call store_saved_registers
# store the number of used registers in 0(sp) -> does not interfere with registers, which is then extracted and reinserted at the end of the procedure
# load stack frame size in s0 and subtract from sp if stack memory is required

# at the end: 
# restore stack frame by adding stack size (s0)
# call restore_saved_registers if store_saved_registers was called at beginning of procedures

# load ra from 4(sp)
# add 8 to sp
# return

# m4_define(`BASE_STACK', 8)
# m4_define(`RET_ADDR', 4)
# m4_define(`USED_REGISTERS', 0)
# m4_define(`A', 65)
# m4_define(`Z', 90)
# m4_define(`a', 97)
# m4_define(`z', 122)
# m4_define(`ASCII_0', 48)
# m4_define(`ASCII_9', 57)
# m4_define(`MIN_CHAR', 32)
# m4_define(`MAX_CHAR', 127)
# m4_define(`SPACE', 32)


# m4_define(`CYPHER_DATA_SIZE', 20)

.text
.global _start
_start:
    la a0, mycypher
    call sanitize_cypher #this trunkates cypher at first character not in accepted_cyphers
                         #necessary because calling the cypher with a bad string breaks the program

    addi sp, sp, -CYPHER_DATA_SIZE
    
    mv a0, sp
    call cypher_data_init #loads cypher data onto stack
    mv a1, a0
    
    la a0, myplaintext
    li a2, 1
    call cypher_iter #procedure is at the bottom of the file
        #(cypher_iter(plaintext, cypher_data, encrypt=true))

    beq x0, a0, exit #if (cypher(...) == null) exit();

    mv a1, sp
    li a2, 0
    call cypher_iter #(cypher_iter(cyphertext, cypher_data, encrypt=false))

    addi sp, sp, CYPHER_DATA_SIZE

    exit:
    li a7, 10
    ecall #exit

.data
    .align 2
    not_implemented_str: .string "Not implemented\n"
.text
not_implemented:
    mv t1, a0
    la a0, not_implemented_str
    li a7, 4
    mv t1, a0
    ret

# m4_define(MYCYPHER_STR, 0)
# m4_define(SOSTK, 4)
# m4_define(BLOCK_KEY, 8)
# m4_define(DICTIONARY_FUNCTION, 12)


#loads the information for running the encryption loop on the given memory address
#a0: encrpt data struct address
cypher_data_init:
    la t0, mycypher
    la t1, sostK
    lb t2, blocKey
    la t3, dictionary_function

    sw t0, MYCYPHER_STR (a0)
    sw t1, SOSTK (a0)
    sw t2, BLOCK_KEY (a0)
    sw t3, DICTIONARY_FUNCTION (a0)

    ret
#return: a0: loaded data structure

.data
    .align 2
    ssr_jump_table: .word ssr_case_12, ssr_case_11, ssr_case_10, ssr_case_9, ssr_case_8, ssr_case_7, ssr_case_6, ssr_case_5, ssr_case_4, ssr_case_3, ssr_case_2, ssr_case_1
.text

store_saved_registers: #expands the stack in order to store all saved registers, to be used in junction with restore...

    lw t6, USED_REGISTERS (sp) #number of used registers is extracted from stack
    # li t0, -4
    # mul t0, t6, t0 
    # add sp, sp, t0
    slli t0, t6, 2 #stack_shift = -4 * register_needed
    la t1, ssr_jump_table
 
    sub sp, sp, t0
    

    # add t0, t1, t0
    sub t0, t1, t0
    addi t2, t0, ASCII_0
    lw t0, 0(t2)
    jr t0 #goto jump_table[12 - register_needed] 

    ssr_case_12:
        sw s11, 48(sp)
    ssr_case_11:
        sw s10, 44(sp)
    ssr_case_10:
        sw s9, 40(sp)
    ssr_case_9:
        sw s8, 36(sp)
    ssr_case_8:
        sw s7, 32(sp)
    ssr_case_7:
        sw s6, 28(sp)
    ssr_case_6:
        sw s5, 24(sp)
    ssr_case_5:
        sw s4, 20(sp)
    ssr_case_4:
        sw s3, 16(sp)
    ssr_case_3:
        sw s2, 12(sp)
    ssr_case_2:
        sw s1, 8(sp)
    ssr_case_1:
        sw s0, 4(sp)

    sw t6, USED_REGISTERS (sp) #number of used registers is inserted on top of stack
    
    ret


.data
    .align 2
    rsr_jump_table: .word rsr_case_12, rsr_case_11, rsr_case_10, rsr_case_9, rsr_case_8, rsr_case_7, rsr_case_6, rsr_case_5, rsr_case_4, rsr_case_3, rsr_case_2, rsr_case_1
    #stores addresses of the switch case
.text

restore_saved_registers: #ectracts all previously saved registers from the stack and shrinks it, to be used in junction with store...

    lw t0, USED_REGISTERS (sp)
    la t1, rsr_jump_table
    #    mul t0, t1, t0 #stack_shift = 4 * register_needed
    slli t0, t0, 2
    
    addi t2, t1, 48 #jump_table + 48
    sub t3, t2, t0 #jump table + (48 - stack_shift)
    lw t3, 0(t3)
    jr t3 #goto jump_table[12 - register_used] 
    
    rsr_case_12:
        lw s11, 48(sp)
    rsr_case_11:
        lw s10, 44(sp)
    rsr_case_10:
        lw s9, 40(sp)
    rsr_case_9:
        lw s8, 36(sp)
    rsr_case_8:
        lw s7, 32(sp)
    rsr_case_7:
        lw s6, 28(sp)
    rsr_case_6:
        lw s5, 24(sp)
    rsr_case_5:
        lw s4, 20(sp)
    rsr_case_4:
        lw s3, 16(sp)
    rsr_case_3:
        lw s2, 12(sp)
    rsr_case_2:
        lw s1, 8(sp)
    rsr_case_1:
        lw s0, 4(sp)
        
    add sp, sp, t0 #stack_ptr + stack_shift
        
    ret
    
strlen:
    mv t0, a0 #moves register with string address to t0
    li a0, 0 #this will iterate over the string
    strlen_loop:
        add t1, t0, a0
        lb t2, 0(t1)
        beq t2, x0, end_strlen_loop #while str[i] != 0

        addi a0, a0, 1
        j strlen_loop
    end_strlen_loop:
    ret


#a0-a5: untouched
#a6: n used_registers
#a7: return address
push_stack:
    addi sp, sp, -BASE_STACK
    sw a7, RET_ADDR (sp)
    sw a6, USED_REGISTERS (sp)

    tail store_saved_registers

pop_stack:
    call restore_saved_registers
    
    lw ra, RET_ADDR (sp)
    addi sp, sp, BASE_STACK

    ret


#d = n/10
#h = d / 10
#d = h - d * 10
#u = n - h * 100 - d * 10


.data
    .align 2
    magic_division10_number: .word 52429
.text

#a0: num a1:dest
btoa:
    andi a0, a0, 0xff # trunkated the three leading bytes
    lw t6, magic_division10_number
    slt t3, x0, a0 #is > 0
    slt t4, a0, x0 #is < 0
    mv t0, a0
    sub t3, t3, t4 #(n > 0) - (n < 0) #sign of n (0 if n == 0)
    
    mul a0, t3, a0 # absolute value of n
    
    mul t1, t6, a0 #n * (1 / 10 * 2^19)
    li t5, 100
    srai t1, t1, 19 #n / 10 
    
    mul t2, t6, t1 #(n / 10) * (1/10 * 2^19)
    li t4, 10
    srai t2, t2, 19 # n / 100
    
    mv t6, a1 #write pointer
    bge t3, x0, btoa_positive
    
    li t3, 45 #'-'
    sb t3, 0(t6)
    addi t6, t6, 1
    btoa_positive:
    blt a0, t4, btoa_units
    blt a0, t5, btoa_tens
    
    addi t3, t2, ASCII_0 #'0'
    sb t3, 0(t6)
    
    mul t2, t2, t4 # n / 100 * 10
    addi t6, t6, 1
    sub t1, t1, t2 # n / 10 - (n / 100 * 10)
    mul t2, t2, t4
    sub t0, t0, t2
    btoa_tens:
    
    addi t3, t1, ASCII_0
    sb t3, 0(t6)
    addi t6, t6, 1
    
    mul t1, t4, t1 # n / 10 % 10 * 10
    sub t0, t0, t1 # n - (n / 10 % 10 * 10)
    
    btoa_units:
        
    addi t3, t0, ASCII_0
    sb t3, 0(t6)
    sb x0, 1(t6)
    
    mv a0, a1
    ret


#return: a0: string 

#copies src into dest up to size - 1 characters and null terminates
#a0: src #a1: dest #a2: size
strlncpy:
    li t0, 0
    bge x0, a2, strlncpy_return #size <= 0
    
    addi t6, a2, -1
    bge t0, t6, strlncpy_null_terminate #if size - 1 has been reached
    strlncpy_loop:

        lb t1, 0(a0)
        addi a0, a0, 1

        sb t1, 0(a1)
        addi a1, a1, 1 #*dest++ = *src++

        beq x0, t1, strlncpy_return #if the string was fully copied
        addi t0, t0, 1
        blt t0, t6, strlncpy_loop #if size - 1 has not been reached

    
    strlncpy_null_terminate:
    
    sb x0, 0(a0)
    # addi t0, t0, 1

    strlncpy_return:
    
    mv a0, t0
    ret    
    
#return : #a0: length of copied string

#a0: src a1: len
strndup:
    addi sp, sp, -4
    sw ra, 0(sp)

    addi sp, sp, -8
    sw a0, 0(sp)
    addi a1, a1, 1
    sw a1, 4(sp)

    mv a0, a1
    call malloc

    beq x0, a0, strndup_return

    mv a1, a0
    lw a0, 0(sp) 
    lw a2, 4(sp)
    call strlncpy

    strndup_return:
    addi sp, sp, 8

    lw ra, 0(sp)
    addi sp, sp, 4
    ret


#args:
#a0: src a1: dest a2:map_function
#saved registers:
#s0: not used 
#s1: src
#s2: dest
#s3: map_function : char (*f)(char)
#s4: i
# m4_define(STR_MAP_UR, 5)
str_map:
    li a6, STR_MAP_UR
    mv a7, ra
    call push_stack

    
    mv s1, a0
    mv s2, a1
    mv s3, a2
    li s4, 0 #for iteration

    str_map_loop:
        add t0, s1, s4
        lb t1, 0(t0)
        beq x0, t1, end_str_map_loop #while str[i] != 0

        mv a0, t1
        jalr ra, s3, 0 # calls map_function(str[i])

        add t0, s2, s4
        sb a0, 0(t0) #str[i] = map_function(str[i])
        beq x0, a0, end_str_map_loop #if the string was null terminated, break loop
        
        addi s4, s4, 1
        j str_map_loop
    end_str_map_loop:
    
    sb x0, 0(t0) #null terminate new string
    mv a0, s2 #return dest

    tail pop_stack

#a0: src, a1: src_len, a2: map_function
str_map_alloc:
    addi sp, sp, -16

    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    sw a2, 12(sp)

    addi a0, a1, 1
    call malloc
    beq x0, a0, return_mapped_string

    mv a1, a0 #dest = mallco(src_len + 1)
    lw a0, 4(sp)
    lw a2, 12(sp)
    call str_map #str_map(src, dest, map_function)

    lw a1, 8(sp) #returns src_len
    return_mapped_string:
    lw ra, 0(sp)
    addi sp, sp, 16
    ret


#a0: address
#a1: size 
bzero: #fills a memory area with zeros
    beq a1, x0, bzero_end
    li t0, 4
    blt a1, t0, bzero_small
    bzero_loop:
    
    
    sw x0, 0(a0)
    addi a1, a1, -4
    addi a0, a0, 4
    bge a1, t0, bzero_loop # if size < 4 -> bzero_small
    beq x0, a1, bzero_end
    
    bzero_small:

    sb x0, 0(a0)
    addi a0, a0, 1
    addi a1, a1, -1

    bne a1, x0, bzero_end # if size == 0 return 
    
    bzero_end:
    ret



#a0: src #a1: dest #a2: size
memcpy:
    beq a2, x0, memcpy_end
    li t0, 4

    slt t6, x0, a2 # size > 0

    slt t3, a1, a0 # dest < src
    slt t4, a0, a1 # src < dest

    sub t5, t3, t4 # (dest < src) - (src < dest)
    # 1 (0b1) with dest < src, -1 (0b...1111) with src < dest, 0 with dest == src 
    and t6, t5, t6 # (size > 0) & (0b1 / 0b..1111 / 0)

    beq t6, x0, memcpy_end # size <= 0 || dest == src

    bgt a0, a1, no_reverse #if (src < dest)
    add a1, a1, a2  #src += size
    add a0, a0, a2  #dest += size

    no_reverse:

    slli t6, t5, 2 #sign *= 4

    blt a2, t0, memcpy_small
    memcpy_loop: #t6 = sign(src - dest) * 4, t0 = 4
    
    lw t3, 0(a0)
    add a0, a0, t6 #src += direction_sign * 4
    
    sw t3, 0(a1)
    add a1, a1, t6 #dest += direction_sign * 4

    addi a2, a2, -4 #sign -= 4

    bge a2, t0, memcpy_loop # if size < 4 -> memcpy_small
    beq x0, a2, memcpy_end #size == 0
    
    memcpy_small: #t5 = sign(src - dest)

    lb t3, 0(a0)
    add a0, a0, t5 #src += sign

    sb t3, 0(a1)
    add a1, a1, t5 #dest += sign

    addi a2, a2, -1 #size--

    bne a2, x0, memcpy_end # if size == 0 return 
    
    memcpy_end:
    ret
    

.data
    magic_division26_number: .word  40330 # used for fixed point math
.text

#args a0: character
caesar_sost:  #FUNCTION TEMPLATE DO NOT CALL WITHOUT CURRYING

    slti t0, a0, 91 # (c <= 'Z')
    li t1, 64
    slt t1, t1, a0 # (c >= 'A')
    and t0, t0, t1

    slti t1, a0, 123 # (c <= 'z')
    li t2, 96
    slt t2, t2, a0 # (c >= 'a')
    and t1, t1, t2

    or t0, t0, t1 # if c is letter
    beq x0, t0, caesar_sost_end

    andi t0, a0, 32 #checks if the letter is lowercase <- every lowercase and upper case letter differs from each other at only at the 6th least sig. bit
    
    addi a0, a0, -A # c -= 'A'
    sub a0, a0, t0 # if (c is lowercase) c -= 32 else c -= 0

    caesar_sost_load_k:
    nop
    nop
    # lb t1 sostK
    add a0, a0, t1
    lw t1, magic_division26_number #2 ^ (4 + 16) / 26 fixed point decimal
    slt t3, a0, x0 #if the number is negative

    mul t1, t1, a0 # temp = ~(2 ^ 20 / 26) * letter_n
    srai t1, t1, 20 #temp /= 2 ^ 20 -> temp = ~(1/26) * letter_n -> ~letter_n/26
    li t2, 26
    add t1, t1, t3 # if the number is negative it will be shifted once more
    mul t1, t1, t2 # round(letter_n / 26) * 26


    sub t1, a0, t1 # a mod b = a - round(a / b) * b -> letter_n mod 26
    
    slt t3, t1, x0
    mul t2, t2, t3 # temp = (modulo < 0) * 26 -> 0 if positive, 26 if negative
    add a0, t1, t2 # c = (letter_n + sostK) % 26 + temp

    addi a0, a0, A # c += 'A'

    add a0, a0, t0 #restores letter case

    caesar_sost_end:
    ret


#args:
#a0: src a1: src_len a2: sostK
caesar_decypher:
    li t0, 26
    sub a2, t0, a2

    tail caesar_encrypt #caesar(src, src_len, 26 - sostK)


#args:
#a0: src a1: src_len a2: sostK
#s0: unused
#s1: src
#s2: src_len
# m4_define(CAESAR_UR, 3)

caesar_encrypt:
    mv a7, ra
    li a6, CAESAR_UR
    call push_stack

    mv s1, a0
    mv s2, a1

    mv a0, a2 #sostk
    li a1, 6 #t1 register
    la a2, caesar_sost_load_k

    call curry_word

    mv a0, s1
    mv a1, s2
    la a2, caesar_sost
    call str_map_alloc

    tail pop_stack

# calls str_map with custom function argument, the function uses the argument value to execute caesar's cypher
# such value is written into the program's text section at runtime
# i think of it as creating a lambda function from a set template by altering one variable


# m4_define(`BLOCK_I_REGISTER', 31) x31 -> t6
# m4_define(`BLOCK_STR_REGISTER', 5) x5 -> t0
# m4_define(`BLOCK_BOOL_REGISTER', 7) x7 -> t2

#a0: character #ONLY CALL AFTER USING CURRY WORD :
block_map:
    block_map_load_i:
    nop #these two are going to be dynamically edited ->    lui t6 ...
    nop #this part loads the counter                        addi t6, t6, ...
    block_map_load_str:
    nop #this part loads the block string pointer           lui t0 .... 
    nop #                                                   addi t0, t0 ...

    lw t5, 0(t6) #t6 will have i address
    add t1, t0, t5 #t0 will have string address
    lb t1, 0(t1)
    bne x0, t1, block_map_continue

    # sb x0, 0(t6)
    lb t1, 0(t0)
    add t5, x0, x0 #resets i to 0

    block_map_check_reverse:
    nop #this part int value for encryption/decryption      lui t2 ....      
    nop #   +1 for encryption, -1 for decryption            add t2, t2, ...

    mul t1, t1, t2 #c *= (encrypt)? 1 : -1

    li t2, ALLOWED_CHARS_N   #max_char - min_char + 1
    li t3, MAX_CHAR   #max_char 

    block_map_continue:
    add a0, a0, t1 #c += block_char

    bounds_check:
    bge t3, a0, within_bounds #if (max_char >= c)

    sub a0, a0, t2
    jal x0, bounds_check
    within_bounds:

    addi t5, t5, 1
    sw t5, 0(t6)

    jalr x0, ra, 0

    block_map_limit: #tag delimits the procedure body, can be used to determine size 
    #(block_map_limit - block_map)
    nop 
# return :#a0 : char


#writes two operations which load a given word 
#a0: word, #a1: register, a2: dest
curry_word:

    #lui t6, x -> x = &var >>(logical) 12
    #0b00000000000000000000?????0110111
    #  [ space for value  ][rd-][opcode]
    #   val >> 12 << 12
    #                       reg << 7
    srli t0, a0, 12
    slli t0, t0, 12 #wipes last 12 bits
    ori t0, t0, 0b0110111 #opcode
    slli t6, a1, 7 # register << 7
    or t0, t0, t6
    sw t0, 0(a2)
    

    
    #ori t6, y -> y = &var & (-1 << 12)
    #0b000000000000?????110?????0010011
    #  [   value  ][rs-][f][-rd][opcode]
    #   value << 20
    #               reg << 15
    #                    reg << 7

    lui t0, 6 #funct3@
    slli t1, a0, 20 #
    ori t0, t0, 0b0010011 #opcode
    or t0, t0, t1
    
    or t0, t0, t6 # reg << 7

    slli t2, a1, 15
    or t0, t0, t2 # reg << 15

    sw t0, 4(a2)

    mv a0, x0
    ret


# m4_define(`CREATE_BLOCK_LAMBDA_UR', 3)

#a0: block_str, a1: &i, a2: bool encrypt/decrypt
#s1: &i
#s2: bool encrypt
create_block_lambda:
    li a6, CREATE_BLOCK_LAMBDA_UR
    mv a7, ra
    call push_stack

    mv s1, a1
    mv s2, a2

    li a1, BLOCK_STR_REGISTER #t0
    la a2, block_map_load_str
    call curry_word #curries block string

    sw x0, 0(s1) #i = 0
    mv a0, s1 #&i
    li a1, BLOCK_I_REGISTER #t6
    la a2, block_map_load_i
    call curry_word #curries iterator address

    slli a0, s1, 1 #bool encrypt *= 2
    addi a0, a0, -1 #bool encrypt * 2 - 1 -> (encrypt)? 1 : -1
    li a1, BLOCK_BOOL_REGISTER #t2
    la a2, block_map_check_reverse
    call curry_word #curries encryption/decryption sign

    tail pop_stack

#args:
#a0: src a1: src_len a2:block_str, a3: bool block_encrypt

#s1: src
#s2: src_len
# m4_define(BLOCK_STACK, 3)
# m4_define(BLOCK_UR, 4)
block:
    li a6, BLOCK_UR
    mv a7, ra
    call push_stack

    addi sp, sp, -BLOCK_STACK #make space for i on the stack

    mv s1, a0 #src_str
    mv s2, a1 #src_len   
    
    mv a0, a2 #load block_str as arg
    add a1, sp, 0 #address of i on the stack
    mv a2, a3
    call create_block_lambda #create_block_lambda(block_str, &i, bool: encrypt) 
    #curries three value into block_map

    mv a0, s1 #src
    mv a1, s2 #src_len
    la a2, block_map

    call str_map_alloc

    addi sp, sp, BLOCK_STACK

    tail pop_stack

# m4_define(`ATTR_ARENA_USED', 0)
# m4_define(`ATTR_ARENA_MAX', 4)
# m4_define(`ARENA_HEADER_SIZE', 8)
#a0: size
new_arena:
    ble x0, a0, failed_arena_init #size <= 0

    addi sp, sp, -8
    sw ra, 0(sp)
    sw a0, 4(sp)

    addi a0, a0, ARENA_HEADER_SIZE
    call malloc #malloc (size + header_size)

    beq x0, a0, arena_return #on malloc fail
    
    lw t0, 4(sp) #reload size
    sw t0, ATTR_ARENA_MAX (a0) #arena.max = size
    sw x0, ATTR_ARENA_USED (a0) #arena.used_memory = 0

    arena_return:

    lw ra, 0(sp)
    addi sp, sp, 8
    
    ret
    failed_arena_init:
        mv a0, x0
        ret

#return: a0 arena obj ptr


#a0: src a1: src_len a2:block_str
block_encrypt:
    li a3, 1
    tail block

block_decypher:
    li a3, 0
    tail block

#a0 : request_size a1: arena_ptr
#s0: stack_frame_size
#s1: return pointer
#s2: arena_ptr
# m4_define(ARENA_ALLOC_STACK, 4)
# m4_define(ARENA_ALLOC_UR, 2)
arena_alloc:    
    sltiu t0, a1, 1 #(arena_ptr == null)
    slti t1, a0, 1 #request_size <= 0
    or t0, t1, t0 

    beq x0, t0, arena_alloc_check_pass
    #automatically fails if (arena_ptr == null || request <= 0)
        mv a0, x0
        ret

    arena_alloc_check_pass:

    li a6, ARENA_ALLOC_UR
    mv a7, ra
    call push_stack
    
    addi sp, sp, -ARENA_ALLOC_STACK
    
    mv s1, x0 #ret_addr = null
    mv s2, a1 #save arena_ptr

    lw t1, ATTR_ARENA_USED (s2) #arena_alloc_size
    lw t2, ATTR_ARENA_MAX (s2) #max_size

    add t3, t1, a0 #t3 = request_size + arena_alloc_size
    bgt t3, t2, arena_alloc_return #if (request_size + arena_alloc_size > arena_alloc_size) return null
    

    sw t3, ATTR_ARENA_USED (s2) #arena_alloc_size += request_size 
    
    addi s1, s2, ARENA_HEADER_SIZE #ptr = arena_ptr + header_size    
    add s1, t1, s1           #ptr = mem_arena + arena_size
    
    mv a1, a0 #request_size
    mv a0, s1 #ret_ptr
    call bzero #bzero(ptr, request_size)

    arena_alloc_return:

    mv a0, s1
    addi sp, sp, ARENA_ALLOC_STACK
    
    tail pop_stack

#return: a0: mem_block_address

# m4_define(`OCCURRENCE_NODE_SIZE', 5)
# m4_define(`ALLOWED_CHARS_N', m4_eval(MAX_CHAR` - 'MIN_CHAR` + 1'))
# m4_define(`OCCURRENCE_MAP_SIZE', m4_eval(ALLOWED_CHARS_N` * 4'))

#a0: occurrence, a1: list_node **node, a2:arena_allocator
#s0: stack_frame_size
#s1: occurrence
#s2: list_node **addr;
# m4_define(ADD_OCCURRENCE_UR, 3)
add_occurrence:
    li a6, ADD_OCCURRENCE_UR
    mv a7, ra
    call push_stack

    lw t0, 0(a1)                #list_node *node = *addr;
    mv s1, a0
    beq x0, t0, new_occurrence_node 

    occ_list_end_search:        #while (node != null)
        addi a1, t0, 1          #*addr = &node->next;
        lw t0, 0(a1)            #node = *addr;
        bne x0, t0, occ_list_end_search

    new_occurrence_node:
    
    mv s2, a1 #save ptr_addr
    
    li a0, OCCURRENCE_NODE_SIZE
    mv a1, a2 #arena
    call arena_alloc        #node = arena_alloc(sizeof(**node), arena)
    beq x0, a0, add_occurrence_return  #if (*node == null) return false
    #if this happens it's because the arena size was not properly set

    sw a0, 0(s2) #*addr = node
    
    andi s1, s1, 0xff #trunkate to byte size
    sb s1, 0(a0) #node->occurrence = occurrence; (*node)->next = null

    li a0, 1 #retval = true

    add_occurrence_return:
    tail pop_stack

#return: a0: true/false depending on the success of allocation


#args: a0 character, a1: occurrence_list, a2: dest, a3: dest_size
#s0: stack_frame_size
#s1: occurrence_list
#s2: dest
#s3: dest_size
#s4: copied_characters
# m4_define(ECO_STACK, 8)
# m4_define(ECO_UR, 6)
encrypt_char_occurrence:
    li a6, ECO_UR
    mv a7, ra
    call push_stack

    addi sp, sp, -ECO_STACK
    
    mv s1, a1
    sub sp, sp, s0
    mv s2, a2
    mv s3, a3
    li t0, 45 #'-'
    sb t0, 0(sp) #initialize char array[8] with '-'

    # li t1, 32
    
    # beq a0, t1, occurrence_encrypt_loop
                     #this part is skipped when character is " " - changed
    sb a0, 0(a2)
    # addi s4, s4, 1
    li s4, 1

    occurrence_encrypt_loop:
        lb a0, 0(s1)
        addi a1, sp, 1 # concats "-" with num string
        call btoa #char[4] num = btoa(occurrence_list->occurrece, num);
        
        
        mv a0, sp #src = char str_num[8]
        sub t0, s3, s4 #dest_size - copied_characters
        addi a2, t0, 1 #dest_size ^ + space for null terminator
        add a1, s2, s4 #dest = dest + copied_characters

        call strlncpy
        add s4, s4, a0 # copied_characters += strlncpy(str_num, dest + copied_characters, dest_size - copied_characters)
        

        lw s1, 1(s1) #occurrece_list = occurrece_list->next

        slt t1, s4, s3 #written_characters < dest_size
        slt t0, x0, s1 #occurrece_list != null
        and t0, t1, t0
        bne x0, t0, occurrence_encrypt_loop

    
    occurrence_encrypt_return:
    
    add t0, s4, s2    #pointer to last character
    mv a0, s4        #return written characters
    sb x0, 0(t0)       #null terminate string
    addi sp, sp, ECO_STACK
    tail pop_stack

#return: a0: copied_characters


#a0: string, #a1: un-initialized_map #a2: arena_allocator
#s0: stack_frame_size
#s1: src
#s2: occurrence_map[max_char + 1 - min_char]
#s3: i
#s4: arena
# m4_define(GOM_STACK, 0)
# m4_define(GOM_UR, 5)
get_occurrence_map:
    mv a7, ra
    li a6, GOM_UR
    call push_stack

    mv s1, a0 #store src
    mv s2, a1 #store occurrence_map
    mv s4, a2 #store mem_arena

    lb t0, 0(a0) #src[0]
    beq x0, t0, occurrence_map_fail #(src[0] == 0)

    mv a0, s2
    li a1, OCCURRENCE_MAP_SIZE
    call bzero #bzero(uninit_occurrence_map, map_size)

    li s3, 0 # i = 0

    get_occurrence_loop:
        add t0, s3, s1 #src + i
        lb t0, 0(t0) #src[i]

        beq x0, t0, occurrence_map_return

        addi t1, t0, -MIN_CHAR      #occurrence = src[i] - min_char
        slli t1, t1, 2      #offset = occurrece * ptr_size
        add a1, s2, t1      #list = occurrence_lists[occurrence]
        addi a0, s3, 1      #occurremce = i + 1
        mv a2, s4
        call add_occurrence #success_add = add_occurrence(i + 1, list, arena_allocator)

        addi s3, s3, 1 #i++
        bne a0, x0, get_occurrence_loop #while (success_add)
    
    occurrence_map_fail: #only falls trhrough if add_occurrence fails
                         #otherwise jumped to
        mv s2, x0 #used for returns

    occurrence_map_return:

    mv a0, s2

    occurrence_map_end:

    tail pop_stack

#return : a0: occurrence_map


#a0: occurrence_map, #a1: src_len
occurrence_dest_size:
    li t0, 0#unique_characters
    li t6, OCCURRENCE_MAP_SIZE #occurrence_map.length() * sizeof(ptr)
    
    li t3, 0 #i = 0
    count_unique_characters: #stores in t0 the count of unique characters
        add t2, a0, t3
        lw t2, 0(t2) #occurrence_map[i]

        sltiu t2, t2, 1 #occurrene_map[i] != null
        add t0, t0, t2 #unique_characters += occurrene_map[i] != null

        addi t3, t3, 4 #i += sizeof(ptr)
        blt t3, t6, count_unique_characters

    get_total_numstr_len:
    # 1024 -> 4 * (1024 + 1 - 1000) + 3 * (1000 - 100) + 2 * (100 - 10) + 1 * (10 - 1)
    #stores in t1 the sum of the length of all integer strings from 1 to src_len
    #for example: 12: "1","2","3",.."10","11","12"-> 1 * 9 + 2 * 3 
    # for (int pow = 10, e = 1; n > pow / 10; pow *= 10, e++) {
    #   count += e * (pow - (pow / 10))
    # }
    # count += e * (n + 1 - pow / 10)
    
    li t1, 0 #count = 0
    li t2, 10 #pow = 10
    li t3, 1 #e = 1
    li t5, 10 #const 10
    li t6, 1 #prev_pow (pow / 10)

    blt a1, t2, remaining_numstrings #if (src_len < 10)
    total_numstring_size_of_len:
        sub t4, t2, t6 #pow - (pow / 10)
        mul t4, t3, t4 #e * (pow - pow  10) 
        add t1, t1, t4 # count += e * (pow - pow / 10)

        addi t3, t3, 1 #e++
        mv t6, t2 #prev_pow = pow
        mul t2, t2, t5 #pow *= 10
        blt t6, a1, total_numstring_size_of_len 

    remaining_numstrings:
    addi t6, t6, -1 #pow / 10 - 1
    sub t6, a1, t6  #src_len + 1 - (pow / 10)
    mul t6, t6, t3 #(src_len + 1 - (pow / 10)) * e
    add t1, t1, t6 # count += (src_len + 1 - (pow / 10)) * e


    total_occurrence_dest_size:

    slli t0, t0, 1 #unique_characters * 2-> there's one character + space for each unique
    addi t0, t0, -1 #except or the first/last
    
    add t0, t0, a1 #unique_chars * 2 + src_len -> there's one '-' for each original character

    add a0, t1, t0 #adding total numstring len
    
    ret


#a0: occurrence_map, #a1: dest_size
#s0: stack_frame_size
#s1: dest
#s2: dest_size
#s3: i
#s4: occurrence_map
#s5: written_characters 

# m4_define(OCCT_STACK, 0)
# m4_define(OCCT_UR, 6)
occurrence_construct_cypher_text:
    li a6, OCCT_UR
    mv a7, ra
    call push_stack

    mv s4, a0
    mv s2, a1 #store dest_size
    
    addi a0, a1, 1
    call malloc #malloc(dest_len + 1)
    mv s1, a0 #store dest ptr

    beq x0, a0, occurrence_construct_return

    li s3, 0 #i = 0
    li s5, 0 #written_characters = 0

    construct_occurrence_ctext_loop:
        
        add a1, s3, s4
        lw a1, 0(a1) #occurrence_lists[i]

        beq x0, a1, next_character_occurrence # if (occurrence_lists[i] == null) continue;

        beq x0, s5, after_separator  #written_characters != 0
        
        add t0, s1, s5 #dest + written_characters
        addi s5, s5, 1 #written_characters++
        beq s5, s2, occurrence_null_terminate #not gonna write separator if max size is reched
        
        li t1, SPACE # ' '
        sb t1, 0(t0) #dest[written_characters++] = ' '

        after_separator:
                   
        srai a0, s3, 2 #translate i from pointer scale to integer -> i / 4
        addi a0, a0, MIN_CHAR #character = i + min_char
        add a2, s1, s5 #dest + written_characters
        sub a3, s2, s5 #max_size - written_characters

        call encrypt_char_occurrence #(char, occ_list, dest, dest_size)

        add s5, s5, a0 #written_characters += retval ^

            next_character_occurrence:
        addi s3, s3, 4 #i += ptr_size

        slt t1, s5, s2 #copied_characters < max_size
        slti t0, s3, OCCURRENCE_MAP_SIZE #i < occurrence_map_size
        and t0, t0, t1
        bne x0, t0, construct_occurrence_ctext_loop
    
    occurrence_null_terminate:
    
    add t0, s1, s5
    sb x0, 0(t0)

    occurrence_construct_return:
    mv a0, s1

    tail pop_stack


#a0: src, a1: src_len
#s0: stack_frame_size
#s1: src
#s2: str_len
#s3: dest
#s4: mem_arena_ptr

# m4_define(`OC_MAP_STACK', 0)
# m4_define(`OCCURRENCE_STACK_SIZE', m4_eval(OCCURRENCE_MAP_SIZE` + 'OC_MAP_STACK))
# m4_define(`OCCURRENCE_UR', 5)
# OC_MAP_STACK (sp)-m4_eval(OCCURRENCE_MAP_SIZE` - 4') (sp): occurrence_lists[ALLOWED_CHARS_N]

occurrence_encrypt:
    mv a7, ra
    li a6, OCCURRENCE_UR
    call push_stack

    addi sp, sp, -OCCURRENCE_STACK_SIZE 

    mv s1, a0
    mv s3, x0 #dest = null

    mv s2, a1 #store src_len

    li t0, OCCURRENCE_NODE_SIZE
    mul t0, s2, t0 #src_len * sizeof(list_node)

    call new_arena #new_arena(src_len * sizeof(list_node))
    beq x0, a0, end_occurrence #if the arena is not available
    mv s4, a0 #save arena_ptr

    mv a2, a0 #arena_ptr as function argument
    mv a0, s1 #src
    addi a1, sp, OC_MAP_STACK #occurrence_map pointer (in the stack)
    
    call get_occurrence_map # (src, &occurrence_map, arena_ptr)
    beq x0, a0, end_occurrence_w_free #if get_occurrence_map == null
    

    #a0: occurrence_map, #a1: src_len
    mv a1, s2
    call occurrence_dest_size #ocds(occurrence_map, src_len)
    mv s2, a0 #str_len = occurrence_dest_size(oc_map, src_len)

    add a0, sp, OC_MAP_STACK #occurrence_map
    mv a1, s2                #dest_len
    call occurrence_construct_cypher_text
    
    end_occurrence_w_free:
    mv s3, a0 #store cyphertext
    mv a0, s4 #arena_ptr
    call free #free(arena_ptr)
    mv a0, s3 #load str
    mv a1, s2 #laod len

    end_occurrence:
    addi sp, sp, OCCURRENCE_STACK_SIZE
    tail pop_stack
#return: a0: dest


# m4_define(`ASCII_TAB', 9) #not needed because 
# m4_define(`ASCII_CR', 13)
# m4_define(`ASCII_+', 43)
# m4_define(`ASCII_-', 45)
#a0: str
atou:
    lb t0, 0(a0)    
    li t1, SPACE

    beq t0, t1, not_space
    atou_skip_space:
        addi a0, a0, 1
        lb t0, 0(a0)
        bne t0, t1, atoi_skip_space

    not_space:
    li t6, 0 #n = 0
 
    li t5, ASCII_9
    slti t1, t0, ASCII_0 #str[0] < '0'
    slt t2, t5, t0 #'9' < str[0] 
    or t1, t1, t2
    beq x0, t1, atou_ret #if str[0] is not a number
    li t4, 10
    atou_loop:
        addi t3, t0, -ASCII_0 #digit = src[0] - '0'
        addi a0, a0, 1 #src++
        
        mul t6, t6, t4 #n *= 10
        # slli t2, t6, 3 #n * 8
        # slli t6, t6, 1 #n * 2
        # add t6, t6, t2 #n* 10 -> 2n + 8n 
        lb t0, 0(a0) #src[0]
        add t6, t6, t3 #n = n * 10 + src[0] - '0'

        slti t1, t0, ASCII_0 #str[0] < '0'
        slt t2, t5, t0 #'9' < str[0] 
        or t1, t1, t2
        bne x0, t1, atou_loop #if str[0] is not a number

    atou_ret:
    mv a0, t6
    ret

#a0: str #a1
strchr:
    li t6, 0
    lb t0, 0(a0)
    beq t0, a1, strchr_end
    beq x0, t0, strchr_end
    strchr_loop:
        addi t6, t6, 1
        add t0, a0, t6
        lb t0, 0(t0)

        bne t0, a1, strchr_end
        bne t0, x0, strchr_end

    strchr_end:
    mv a0, t6

    ret

# m4_define(`OCCURRENCE_PT_UR', 5)
#a0: cypher_text
#s1: str
#s2: max_num
#s3: i
#s4: '-'
occurrence_plaintext_size:
    li a6, OCCURRENCE_PT_UR
    mv a7, ra
    call push_stack

    mv s1, a0 #store str
    mv s2, x0 #max_num = 0
    mv s3, x0 #i = 0
    li s4, ASCII_- #'-'

    lb t0, 0(s1) #str[0]
    beq x0, t0, plaintext_size_ret
    beq s4, t0, found_dash
    occurrence_ct_iter:
        next_dash:
            addi s3, s3, 1#i++

            lb t0, 0(a0)
            # xori t1, t0, ASCII_- # str[i] != -
            # sltiu t2, t0, 1      # str[i] == 0
            # sltiu t1, t1, 1      # (str[i] != '-') == 0 -> str[i]
            # or t1, t1, t2
            # beq x0, t1, next_dash #strp
            beq x0, t0, plaintext_size_ret
            bne s4, t0, next_dash
        found_dash:
            addi s3, s3, 1 #i++
            lb t0, 0(s1) #src[i]
        beq t0, s4, found_dash #src[i] == '-'

        after_dash:

        add a0, s1, s3 #str + i
        call atou
        bge s2, a0, next_dash #(atou(&str[i]) < max_num)
        store_max:
            mv s2, a0 #max_num = atou(&str[i])

        j next_dash

    plaintext_size_ret:
    mv a0, s2
    tail pop_stack
#return: a0: plaintext_len

# m4_define(`RCBO_UR', 6)
#a0: cypher_text, a1:dest, a2: iter_limit
#s1: cypher_text
#s2: dest
#s3: i
#s4: char
#s5: iter_limit
restore_char_by_occurrence:
    li a6, RCBO_UR
    mv a7, ra
    call push_stack

    mv s1, a0 #store cypher_text
    mv s2, a1 #store dest
    li s3, 2  #i = 2
    lb s4, 0(s1) #char = cypher_text[0]
    mv s5, a2

    char_occurrence_loop:
        add a0, s1, s3 #src + i
        call atou

        add t0, a0, s2
        sb s4, 0(t0)# dest[atou(src + i)] = char
    
        add a0, s1, s3 #src + i
        li a1, ASCII_- # '-'
        call strchr #strchr(src + i, '-') advances to next '-'
        add s3, a0, 1 #i = strchr(src + i, '-') + 1

        blt s3, s5, char_occurrence_loop #while i < strchr(src, ' ')

    restore_char_by_occurrence_end:

    tail pop_stack

# m4_define(`OCPT_UR', 6)
#a0: src #a1: dest
#a0: cypher_text
#s1: str
#s2: max_num
#s3: i
#s4: dest
#s5: next_group
occurrence_construct_plain_text:
    li a6, OCPT_UR
    mv a7, ra
    call push_stack

    mv s1, a0 #store str
    mv s2, x0 #max_num = 0
    # mv s3, x0 #i = 0
    mv s4, a1 #store dest
    li s5, -1 #next_group = -1

    occurrence_ct_iter:
        addi s3, s5, 1 #i = next_group + 1
        add a0, s1, s3 #src + i
        li a1, SPACE   #' '
        call strchr    #strchr(src + i, ' ')
        mv s5, a0 #next_group = strchr(src + 1, ' ') #next space / str end

        add a0, s1, s3  #src + i
        mv a1, s4       #dest
        mv a2, s5       #next_group
        call restore_char_by_occurrence #restore...(src + i, dest, strchr(src + i, ' '))

        add t0, s1, s5
        lb t0, 0(t0)
        bne x0, t0, occurrence_ct_iter

    plaintext_size_ret:
    mv a0, s2
    tail pop_stack


#m4_define(`OCCURRENCE_DECYPHER_UR', 3)
#a0: cypher_text, #a1: src_len
#s1: cypher_text
#s2: str_len
occurrence_decypher:
    li a6, OCCURRENCE_DECYPHER_UR
    mv a7, ra 
    call push_stack

    mv s1, a0
    
    call occurrence_plaintext_size
    mv s2, a0 #store dest_len

    addi a0, a0, 1
    call malloc

    beq x0, a0, occurrence_decypher_ret

    mv a1, a0 #malloc return
    mv a0, s1 #src

    call occurrence_construct_plain_text
    
    add t0, s2, s1 #pointer to end str
    sb x0, 0(t0) #null terminate

    occurrence_decypher_ret:

    mv a1, s2
    tail pop_stack
#return: a0: plain text

#a0: one character

dictionary_function:

    li t0, A #'A'
    li t1, Z #'Z'

    blt a0, t0, not_upper
    bgt a0, t1, not_upper #if (c >= 'A' && c <= 'Z')
    
        li t1, z #'z'
    
    j end_dict_if
    not_upper:
        li t0, a #'a'
        li t1, z #'z'
        blt a0, t0, not_letter
        bgt a0, t1, not_letter  #if (c >= 'a' && c <= 'z')

        li t1, Z #'Z'

        j end_dict_if
    not_letter:
        li t0, ASCII_0 #'0'
        li t1, ASCII_9 #'9'
        blt a0, t0, not_alphanumeric
        bgt a0, t1, not_alphanumeric # if (c >= '0' && c <= '9')
    
        nop
    
        j end_dict_if
    not_alphanumeric: #else
        ret # stays the same
    end_dict_if:

    sub a0, a0, t0 
    sub a0, t1, a0 #c = max_new_range - (c - min_old_range)
    #3 cases:
    #c = 'z' - ('[A-Z]' - 'A')
    #c = 'Z' - ('[a-z]' - 'a')
    #c = '9' - ('[0-9]' - '0')
    ret
#returned:
#a0: the character after being elaborated by the dictionary function 








#args:
#a0: src a1: src_len a2:dictionary_function
dictionary:
    tail str_map_alloc


#args:
#a0: src, a1: src_len
#vars:
#s1: the string to be reversed (src)
#s2: the string's length (len)
#s3: i
#s4: the string to be returned (dest)
# m4_define(INV_UR, 5)
inversion:
    li a6, INV_UR
    mv a7, ra
    call push_stack
    # prologue

    mv s1, a0 #store src
    mv s4, x0 #dest = null
    mv s2, a1 #len = strlen(src)

    addi a0, a1, 1
    call malloc #malloc (src_len + 1)
    beq x0, a0, end_inversion #if malloc fails, inversion returns null

    mv s6, a0 #dest = malloc(src_len + 1)

    li s3, 0 #i = 0
    beq s3, s2, end_inv_loop #skip loop if len is zero
    inv_loop:
        add t0, s1, s3 #&src[i]
        lb t0, 0(t0) #c = src[i]

        sub t1, s2, s3 #len - i
        add t1, s4, t1 #&dest[len - i]
        sb t0, -1(t1) #dest[len - i - 1] = src[i]

        addi s3, s3, 1 #i++
        bne s3, s2, inv_loop #while (i < len)
    end_inv_loop:

    add t0, s4, s2 # &dest[len]
    sb x0, 0(t0) #dest[len] = 0 null termination

    end_inversion: #end of the procedure, restores the stack and returns the inverted string
    mv a0, s6 #to return the string
    mv a1, s2 #to return the string's length
    add t0, a0, s2
    sb x0, 0(t0) #null terminate
    
    tail pop_stack

#
#a0, character 
char_sanitizer:
    li t0, 0
    la t1, accepted_cyphers
    
    sanitizer_loop:
        add  t2, t1, t0
        lb t2, 0(t2)
        beq x0, t2, end_sanitizer_loop
        bne t2, a0, mismatched_char #if (c == accepted_characters[i])
            ret                     #    return c

        mismatched_char:
        addi t0, t0, 1
        j sanitizer_loop
    end_sanitizer_loop:
        
    mv a0, x0 #return 0 
    ret 


#trunkates cypher at the first character that isn't allowed by project requirement
#lazy but quick to write
sanitize_cypher:
    # addi sp, sp, -BASE_STACK
    # sw ra, RET_ADDR (sp)
    
    mv a1, a0
    la a2, char_sanitizer
    # call str_map
    tail str_map
    
    # lw ra, RET_ADDR (sp)
    # addi sp, sp, BASE_STACK
    # ret
    
    
    
.data
        .align 2
    encrpt_jump_table: .word encrypt_case_A, encrypt_case_B, encrypt_case_C, encrypt_case_D, encrypt_case_E
    decypher_jump_table: .word decypher_case_A, decypher_case_B, decypher_case_C, decypher_case_D, decypher_case_E 
.text


    encrpt_init:
    la s6, encrpt_jump_table #sets up jump table for encryption 
    li s3, 0  #i = 0
    li s4, 1 #increment = 1
    mv s5, a0 #iteration_end = strlen(cypher_data.cypher)

    j cypher_loop
    
    decypher_init:
    addi s3, a0, -1 #start from len - 1

    la s6, decypher_jump_table #sets up jump table for decryption
    li s4, -1 # increment = -1
    li s5, -1 #iterate until i >= 0

    J cypher_loop

#a0: object_text
#a1: t_cypher_data: {cypher, sostK, blocKey, dictionary_func}
#a2: bool : encrypt

#saved registers:
#s1: to encrypt
#s2: cypher_data
#s3: i to iterate over cypher
#s4: i increment
#s5: iter_stop
#s6: jump table address
#s7: bool : first_cycle 
#s8: src_len

#cypher string is assumed to be properly formatted

#procedure iterates over the mycypher string, at each cycle switching between 5 cases depending on each character
#depending on the "encrypt" argument boolean in a2 the cases encrypt or decrypt the string
#in each case, one of the 5 defined encrypting procedures is called with its associated arguments

# encrypting procedure convention: a0: src_str, a1: src_len, a2: encryption_key/dictionary_function 
# -> return (a0: encryption str, // to implement: a1: len)
# m4_define(CYHPER_STACK, 4)
# m4_define(CYPHER_UR,  9)
cypher_iter:
    mv a7, ra
    li a6, CYPHER_UR
    call push_stack

    addi sp, sp, -CYHPER_STACK
    # stack management prologue


    mv s1, a0 #char *to_encrypy = plaintext
    mv s2, a1 #save cypher_data pointer
    li s7, 1 #first_cycle = true

    call strlen #strlen(src)
    mv s8, a0
    
    lw a0, MYCYPHER_STR (s2)
    call strlen #strlen (cypher_data.cypher) 

    beq a0, x0, end_cypher_loop #cypher_data.cypher.lenght() == 0

    bne a5, x0, encrpt_init # if (encrypt == false)
    j decypher_init 
    #used to be in procedure body but i extracted it for readability's sake

    cypher_loop:
        lw t1, MYCYPHER_STR (s2)
        add t0, t1, s3  #mychypher + i
        mv a0, s1                   #load text to encrypt as argument
        mv a1, s8                   #laod src_len as argument
        lb t0, 0(t0)    #mycypher[i]

        cypher_switch:
        addi t0, t0, -A #temp = mycypher[i] - 'A'
        slli t0, t0, 2 #temp *= 4
        add t0, s6, t0 #temp += &jump_table
        
        lw t0, 0(t0)   #dereference
        jr t0 # jump to (addresses [str[i] - 'A'])

        encrypt_case_A:
            lw a2, SOSTK (s2) #loads sostk as argument
            call caesar_encrypt
            j end_cypher_switch
        decypher_case_A:
            lw a2, SOSTK (s2)
            call caesar_decypher
            j end_cypher_switch

        encrypt_case_B:
            lw a2, BLOCK_KEY (s2) #loads blockKey as argument
            call block_encrypt
            j end_cypher_switch
        decypher_case_B:
            lw a2, BLOCK_KEY (s2) #
            call block_decypher #block_decypger
            j end_cypher_switch

        encrypt_case_C:
            call occurrence_encrypt #occurrence(src)
            j end_cypher_switch
        decypher_case_C:
            call occurrence_decypher #occurrence_decypher(src)
            j end_cypher_switch

        encrypt_case_D: decypher_case_D: #same behavior
            lw a2, DICTIONARY_FUNCTION (s2) #load dictionary function pointer as argument
            call dictionary #dictionary(src, char (*f)(char))
            j end_cypher_switch

        encrypt_case_E: decypher_case_E: #same behavior
            call inversion #inversion(src)
            # j end_cypher_switch
        end_cypher_switch:

        mv t0, s1 #saves src_string to temp register
        mv s1, a0 #stores returned string
        mv s8, a1 #save src_len
        bne s7, x0, no_free_src #if (first_cycle == true) -> skip free(src)
        free_src:
            
            mv a0, t0 #loads src_str as argument
            call free #free(src_str)
             
        no_free_src:

        mv s7, x0 #first_cycle = false
        
        print_result_text:
        li a7, 4
        ecall # prints encrypted string
        li a0, 10 #\n
        li a7, 11 #printchar
        ecall #putchar(\n)

        add s3, s3, s4 #i += increment
        bne s3, s5, cypher_loop #while(i != end)
    end_cypher_loop:

    
    # restoring stack and return epilogue
    addi sp, sp, CYHPER_STACK
    tail pop_stack
