.data
    myplaintext: .string "STUDENTE"
    max_size: .byte 200
    mpt_buffer: .zero 200
    mycypher: .string "A"
    mycypher_buffer: .zero 200
    blocKey: .string "OLA"
    .blocKey_buffer: .zero 200
    sostK: .byte -25
    min_char: .byte 32
    max_char: .byte 127
    block_stack_size: .word 4  
    cypher_jump_table: .zero 20
    decypher_jump_table: .word decypher_case_A, decypher_case_B
    ssr_jump_table: .zero 48
    rsr_jump_table: .zero 48
    arena_in_use: .byte 0
    arena_alloc_size: .word 0 #
    arena_size: .word 1400 # 1000 + 384
    mem_arena: .zero 1000 # max_size * 5 used to allocate linked list nodes for occurrence cypher
    default_str: .string "default"
    default_cypher: .string "ABCDE" 
    accepted_cyphers: .string "ABCDE" #for the sanitizer to trunkate the cypher string at the first occurrence of a character not in this string
    newline: .string "\n"
    not_implemented_str: .string "Not implemented\n"
    magic_division26_number: .word  40330 # used for fixed point math
    magic_dicision10_number: .word 52429
    
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

# define(BASE_STACK, 8)
# deine (RET_ADDR, 4)
# deine (USED_REGISTERS, 0)
# deine (A, 65)
# deine (Z, 90)
# deine (a, 97)
# deine (z, 122)
# deine (ASCII_0, 48)
# deine (ASCII_9, 57) 
.text

main:

    call load_jump_tables

    la a0, mycypher
    call sanitize_cypher #this trunkates cypher at first character not in accepted_cyphers
                         #necessary because calling the cypher with a bad string breaks the program


    la a0, myplaintext
    la a1, mycypher
    lb a2, sostK
    la a3, blocKey
    la a4, dictionary_function

    call cypher_iter #procedure is at the bottom of the file
    
    mv s1, a0

    li a7, 10
    ecall #exit

not_implemented:
    mv t1, a0
    la a0, not_implemented_str
    li a7, 4
    mv t1, a0
    ret
    


load_jump_tables:
    load_ssr_jt:
        la t0, ssr_jump_table
        la t1, ssr_case_12
        la t2, ssr_case_11
        la t3, ssr_case_10
        la t4, ssr_case_9
        sw t1, 0(t0)
        sw t2, 4(t0)
        sw t3, 8(t0)
        sw t4, 12(t0)
        la t1, ssr_case_8
        la t2, ssr_case_7
        la t3, ssr_case_6
        la t4, ssr_case_5
        sw t1, 16(t0)
        sw t2, 20(t0)
        sw t3, 24(t0)
        sw t4, 28(t0)
        la t1, ssr_case_4
        la t2, ssr_case_3
        la t3, ssr_case_2
        la t4, ssr_case_1
        sw t1, 32(t0)
        sw t2, 36(t0)
        sw t3, 40(t0)
        sw t4, 44(t0)
    
    load_rsr_jt:
        la t0, rsr_jump_table
        la t1, rsr_case_12
        la t2, rsr_case_11
        la t3, rsr_case_10
        la t4, rsr_case_9
        sw t1, 0(t0)
        sw t2, 4(t0)
        sw t3, 8(t0)
        sw t4, 12(t0)
        la t1, rsr_case_8
        la t2, rsr_case_7
        la t3, rsr_case_6
        la t4, rsr_case_5
        sw t1, 16(t0)
        sw t2, 20(t0)
        sw t3, 24(t0)
        sw t4, 28(t0)
        la t1, rsr_case_4
        la t2, rsr_case_3
        la t3, rsr_case_2
        la t4, rsr_case_1
        sw t1, 32(t0)
        sw t2, 36(t0)
        sw t3, 40(t0)
        sw t4, 44(t0)

    load_cypher_jt:
        la t5, cypher_jump_table

        la t0, cypher_case_A
        la t1, cypher_case_B
        la t2, cypher_case_C
        la t3, cypher_case_D
        la t4, cypher_case_E
        sw t0, 0(t5)
        sw t1, 4(t5)
        sw t2, 8(t5)
        sw t3, 12(t5)
        sw t4, 16(t5)

    load_decypher_jt:
        la t5, decypher_jump_table

        la t0, decypher_case_A
        la t1, decypher_case_B
        la t2, decypher_case_C
        la t3, decypher_case_D
        la t4, decypher_case_E
        sw t0, 0(t5)
        sw t1, 4(t5)
        sw t2, 8(t5)
        sw t3, 12(t5)
        sw t4, 16(t5)   

    
    ret

        
    #stores the addresses of the various switch cases in the data section 
    #would have preferred using macros or embedding into the text section, but it wasn't supported by ripes



store_saved_registers: #expands the stack in order to store all saved registers, to be used in junction with restore...

    lw t6, USED_REGISTERS(sp) #number of used registers is extracted from stack
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

    sw t6, USED_REGISTERS(sp) #number of used registers is inserted on top of stack
    
    ret


restore_saved_registers: #ectracts all previously saved registers from the stack and shrinks it, to be used in junction with store...

    lw t0, USED_REGISTERS(sp)
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


#d = n/10
#h = d / 10
#d = h - d * 10
#u = n - h * 100 - d * 10


#a0: num a1:dest
btoa:
    andi a0, a0, 0xff # trunkated the three leading bytes
    lw t6, magic_dicision10_number
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
    bge x0, a2, strlcpy_return #size <= 0
    
    addi t6, a2, -1
    bge t0, t6, strlcpy_null_terminate #if size - 1 has been reached
    strlcpy_loop:

        lb t1, 0(a0)
        addi a0, a0, 1

        sb t1, 0(a1)
        addi a1, a1, 1 #*dest++ = *src++

        beq x0, t1, strlcpy_return #if the string was fully copied
        addi t0, t0, 1
        blt t0, t6, strlcpy_loop #if size - 1 has not been reached

    
    strlcpy_null_terminate:
    
    sb x0, 0(a0)
    # addi t0, t0, 1

    strlcpy_return:
    
    mv a0, t0
    ret    
    
#return : #a0: length of copied string






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
    addi sp, sp, -BASE_STACK
    sw ra, RET_ADDR(sp)

    li t0, STR_MAP_UR
    sw t0, USED_REGISTERS(sp)
    call store_saved_registers

    
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

    call restore_saved_registers
    lw ra, RET_ADDR(sp)
    addi sp, sp, BASE_STACK
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
#a0: src a1: dest a2: sostK
caesar_decypher:
    li t0, 26
    sub a2, t0, a2

    tail caesar




#args:
#a0: src a1: dest a2: sostK
#s0: unused
#s1: src
#s2: dest
# m4_define(CAESAR_UR, 3)

caesar:
    addi sp, sp, -BASE_STACK
    sw ra, RET_ADDR(sp)
    li t0, CAESAR_UR
    sw t0, USED_REGISTERS(sp)

    call store_saved_registers

    mv s1, a0
    mv s2, a1

    mv a0, a2 #sostk
    li a1, 6 #t1 register
    la a2, caesar_sost_load_k

    call curry_word

    mv a0, s1
    mv a1, s2
    la a2, caesar_sost
    call str_map

    call restore_saved_registers
    lw ra, RET_ADDR(sp)
    addi sp, sp, BASE_STACK
    ret

# calls str_map with custom function argument, the function uses the argument value to execute caesar's cypher
# such value is written into the program's text section at runtime
# i think of it as creating a lambda function from a set template by altering one variable


#a0: character #ONLY CALL AFTER USING CURRY WORD :
block_encrypt:
    block_encrypt_load_i:
    nop #these two are going to be dynamically edited ->    lui t6 ...
    nop #this part loads the counter                        addi t6, t6, ...
    block_encrypt_load_str:
    nop #this part loads the block string pointer           lui t0 .... 
    nop #                                                   addi t0, t0 ...

    lw t5, 0(t6) #t6 will have i address
    add t1, t0, t5 #t0 will have string address
    lb t1, 0(t1)
    bne x0, t1, block_encrypt_continue


    # sb x0, 0(t6)
    lb t1, 0(t0)
    add t5, x0, x0

    block_encrypt_continue:
    addi t2, x0, 0 #min_char #gonna be edited
    addi t3, x0, 0 #max_char #gonna be edited

    sub t2, t3, t2
    addi t2, t2, 1  #max_char - min_char + 1

    add a0, a0, t1 #c += block_char

    bounds_check:
    bge t3, a0, within_bounds #if (max_char >= c)

    sub a0, a0, t2
    jal x0, bounds_check
    within_bounds:

    addi t5, t5, 1
    sw t5, 0(t6)

    jalr x0, ra, 0

    block_encrypt_limit:
    nop
# return :#a0 : char



block_decypher:



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



#args:
#a0: src a1: dest a2:block_str

#s0: stack_size
#s1: src
#s2: dest
# m4_define(BLOCK_STACK, 4)
# m4_define(BLOCK_UR, 4)
block:
    addi sp, sp, -BASE_STACK
    sw ra, RET_ADDR(sp)

    li t0, BLOCK_UR
    sw t0, USED_REGISTERS(sp)
    call store_saved_registers

    addi sp, sp, -BLOCK_UR

    mv s1, a0 #src_str
    mv s2, a1 #dest_str

    mv a0, a2 #block_str
    li a1, 5 #t0
    la a2, block_encrypt_load_str
    call curry_word


    sw x0, 0(sp) #i = 0
    mv a0, sp #&i
    li a1, 31 #t6
    la a0, block_encrypt_load_i
    call curry_word



    mv a0, s1 #src
    mv a1, s2 #dest
    la a2, block_encrypt

    call str_map

    addi sp, sp, BLOCK_STACK
    call restore_saved_registers
    lw ra, RET_ADDR(sp)
    addi sp, sp, -BASE_STACK

    ret

#\sadd(\s+)\b([a-z][a-z]|[0-9])\b,((\s+)(\b([a-z][a-z]|[0-9])\b,+(\s+)x0)|(x0,(\s+\b([a-z][a-z]|[0-9])\b)))

arena_init:
        la t0, arena_in_use
        lb t1, 0(t0)
        
        bne x0, t1, failed_arena_init #when the arena is in use
        
        li a0, 1    #return true
        la t1, arena_alloc_size
        sb a0, 0(t0) #in use = 1
        sw x0, 0(t1) #size = 0
        
        ret
        
        failed_arena_init:
            mv a0, x0 #return false
            ret

arena_clear:
    la t0, arena_alloc_size
    lb t1, arena_in_use
    sw x0, 0(t0) #sets allocated size to 0
    sb x0, 0(t1) #sets in_use status to false
    
    ret




arena_safeguard:
    mv a0, x0
    ret


#a0 : request_size
#s0: stack_frame_size
#s1: return pointer
# m4_define(ARENA_ALLOC_STACK, 4)
# m4_define(ARENA_ALLOC_UR, 2)
arena_alloc:    
    lb t0, arena_in_use
    beq x0, t0, arena_safeguard #automatically fails if the arena is not in use
    
    addi sp, sp, -BASE_STACK
    sw ra, RET_ADDR(sp)

    li t0, ARENA_ALLOC_UR
    sw t0, USED_REGISTERS(sp) 
    call store_saved_registers
    mv s1, x0 #ret_addr = null
    addi sp, sp, -ARENA_ALLOC_STACK

    
    mv a1, a0

    lw t1, arena_alloc_size
    lw t2, arena_size


    add t3, t1, a0 #t3 = request_size + arena_alloc_size
    bgt t3, t2, arena_alloc_return #if (request_size + arena_alloc_size > arena_alloc_size) return null
    

        la t4, arena_alloc_size 
    la a0, mem_arena   
        sw t3, 0(t4)             #arena_alloc_size += request_size 
    add a0, t1, a0           #ptr = mem_arena + arena_size
    
    
    mv s1, a0                #ret_addr = ptr
    call bzero


    arena_alloc_return:

        mv a0, s1
        addi sp, sp, ARENA_ALLOC_STACK
        call restore_saved_registers
        lw ra, RET_ADDR(sp)
        addi sp, sp, BASE_STACK
        ret

#return: a0: mem_block_address

#a0: occurrence, a1: list_node **node
#s0: stack_frame_size
#s1: occurrence
#s2: list_node **addr;
# m4_define(ADD_OCCURRENCE_UR, 3)
add_occurrence:
    addi sp, sp, -BASE_STACK
    sw ra, RET_ADDR(sp)
    li t0, ADD_OCCURRENCE_UR
    sw t0, USED_REGISTERS(sp)
    call store_saved_registers

    lw t0, 0(a1)                #list_node *node = *addr;
    mv s1, a0
    beq x0, t0, new_occurrence_node 

    occ_list_end_search:        #while (node != null)
        addi a1, t0, 1          #*addr = &node->next;
        lw t0, 0(a1)            #node = *addr;
        bne x0, t0, occ_list_end_search

    new_occurrence_node:
    
    mv s2, a1 #save ptr_addr
    
    li a0, 5
    call arena_alloc        #node = arena_alloc(sizeof(**node))
    beq x0, a0, add_occurrence_return  #if (*node == null) return false
    #if this happens it's because the arena size was not properly set

    sw a0, 0(s2) #*addr = node
    
    andi s1, s1, 0xff #trunkate to byte size
    sb s1, 0(a0) #node->occurrence = occurrence; (*node)->next = null

    li a0, 1 #retval = true

    add_occurrence_return:
    call restore_saved_registers
    lw ra, RET_ADDR(sp)
    addi sp, sp, BASE_STACK

    ret

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
    addi sp, sp, -BASE_STACK
    sw ra, RET_ADDR(sp)

    li t0, ECO_UR
    sw t0, USED_REGISTERS(sp)
    call store_saved_registers
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
        add s4, s4, a0 # copied_characters += strlcpy(str_num, dest + copied_characters, dest_size - copied_characters)
        

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
    call restore_saved_registers
    lw ra, RET_ADDR(sp)
    addi sp, sp, -BASE_STACK
    
    ret

#return: a0: copied_characters


#a0: string, #a1: min_char #a2: max_char
#s0: stack_frame_size
#s1: min_char
#s2: src
#s3: i
#s4: occurrence_map[max_char + 1 - min_char]
#s5: map_size
# m4_define(GOM_STACK, 4)
# m4_define(GOM_UR, 6)
get_occurrence_map:
    addi sp, sp, -BASE_STACK
    sw ra, RET_ADDR(sp)

    li t0, GOM_UR
    sw t0, USED_REGISTERS(sp)

    call store_saved_registers
    addi sp, sp, -GOM_STACK

    mv s2, a0
    mv s1, a1

    sub t0, a2, a1
    addi t1, t0, 1 #size = max_c - min_c + 1
    slli s5, t0, 2 #occurrence_map_size *= sizeof_ptr

    lb t1, 0(a0) #src[0]
    slt t0, x0, s5 #(map_size > 0)
    sltu t1, x0, t1 #src[0] != 0

    and t0, t0, t1
    beq x0, t0, occurrence_map_fail #(map size <= 0 ||  src[0] != 0)

    mv a0, s5

    call arena_alloc
    beq x0, a0, occurrence_map_fail

    mv s4, a0   #stores pointer to array
    li s3, 0 # i = 0
    

    get_occurrence_loop:
        add t0, s3, s2
        lb t0, 0(t0)

        beq x0, t0, occurrence_map_return

        sub t1, t0, s1      #occurrence = src[i] - min_char
        slli t1, t1, 2      #offset = occurrece * ptr_size
        add a1, s4, t1      #list = occurrence_lists[occurrence]
        addi a0, s3, 1      #occurremce = i + 1
        call add_occurrence #success_add = add_occurrence(i + 1, list)

        addi s3, s3, 1 #i++
        bne a0, x0, get_occurrence_loop #while (success_add)
    
    occurrence_map_fail: #only falls trhrough if add_occurrence fails
                         #otherwise jumped to
    mv s4, x0 #used for returns
    mv s5, x0

    occurrence_map_return:

    mv a0, s4
    mv a1, s5

    occurrence_map_end:

    addi sp, sp, GOM_STACK
    call restore_saved_registers
    lw ra, RET_ADDR(sp)
    addi sp, sp, BASE_STACK
    ret

#return : a0: occurrence_map a1: map_size

#a0: dest, #a1: dest_size, #a2: min_char, #a3: occurrence_map, #a4: map_size
#s0: stack_frame_size
#s1: dest
#s2: dest_size
#s3: i
#s4: occurrence_map
#s5: map_size
#s6: min_char
#s7: written_characters 

# m4_define(OCCT_STACK, 4)
# m4_define(OCCT_UR, 8)
occurrence_construct_cypher_text:
    addi sp, sp, -BASE_STACK
    sw ra, RET_ADDR(sp)

    li t0, OCCT_UR
    sw t0, USED_REGISTERS(sp)
    call store_saved_registers

    addi sp, sp, -OCCT_STACK

    mv s1, a0
    mv s2, a1
    mv s4, a3
    mv s5, a4
    mv s6, a2


    li s3, 0 #i = 0
    li s7, 0 #written_characters = 0

    construct_occurrence_ctext_loop:
        
        add a1, s3, s4
        lw a1, 0(a1) #occurrence_lists[i]

        beq x0, a1, next_character_occurrence # if (occurrence_lists[i] == null) continue;

        beq x0, s7, after_separator  #written_characters != 0
        
        add t0, s1, s7 #dest + written_characters
        addi s7, s7, 1 #written_characters++
        beq s7, s2, occurrence_null_terminate #not gonna write separator if max size is reched
        
        li t1, 32 # ' '
        sb t1, 0(t0) #dest[written_characters++] = ' '

        after_separator:
                   
        srai a0, s3, 2 #translate i from pointer scale to integer -> i / 4
        add a0, a0, s6 #character = i + min_char
        add a2, s1, s7 #dest + written_characters
        sub a3, s2, s7 #max_size - written_characters

        call encrypt_char_occurrence #(char, occ_list, dest, dest_size)

        add s7, s7, a0 #written_characters += retval ^

            next_character_occurrence:
        addi s3, s3, 4 #i += ptr_size

        slt t1, s7, s2 #copied_characters < max_size
        slt t0, s3, s5 #i < occurrence_map_size
        and t0, t0, t1
        bne x0, t0, construct_occurrence_ctext_loop
    
    occurrence_null_terminate:
    
    add t0, s1, s7
    sb x0, 0(t0)


    occurrence_return:
    mv a0, s1

    addi sp, sp, OCCT_STACK
    call restore_saved_registers
    lw ra, RET_ADDR(sp)
    addi sp, sp, -BASE_STACK

    ret



#a0: src a1:dest
#s0: stack_frame_size
#s1: min_char
#s2: src
#s3: dest

#0(sp)-380(sp): occurrence_lists[96] -> moved to areana allocator
# m4_define(OCCURRENCE_STACK_SIZE, 0)
# m4_define(OCCURRENCE_UR, 4)

occurrence:

    addi sp, sp, -BASE_STACK
    sw ra, RET_ADDR(sp)
    li t0, OCCURRENCE_UR
    sw t0, USED_REGISTERS(sp)
    call store_saved_registers

    addi sp, sp, -OCCURRENCE_STACK_SIZE 

    lb s1, min_char
    mv s2, a0
    lw t6, max_size
    mv s3, a1

    ble t6, x0, end_occurrence #if (input_len == 0 || dest_size <= 0) return src;

    call arena_init
    beq x0, a0, end_occurrence #if the arena is not available
    
    mv a0, s2 #src
    mv a1, s1 #min_char
    lb a2, max_char
    
    call get_occurrence_map # (src, min_character, max_char)
    beq x0, a0, end_occurrence_w_free #if get_occurrence_map == null

    mv a3, a0 #occurrence_map
    mv a4, a1 #map_size
    
    #a0: dest, #a1: dest_size, #a2: min_char, #a3: occurrence_map, #a4: map_size
    mv a2, s1
    mv a0, s3 #dest
    lw a1, max_size 
    call occurrence_construct_cypher_text
    
    end_occurrence_w_free:
    call arena_clear

    end_occurrence:
    addi sp, sp, OCCURRENCE_STACK_SIZE
    call restore_saved_registers

    lw ra, RET_ADDR(sp)
    addi sp, sp, BASE_STACK
    ret
#return: a0: dest





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
#a0: src a1: dest a2:dictionary_function
dictionary:
    addi sp, sp, -BASE_STACK
    sw ra, RET_ADDR(sp)
    
    call str_map

    lw ra, RET_ADDR(sp)
    addi sp, sp, BASE_STACK
    ret



#args:
#a0: src, a1: dest
#vars:
#s1: the string to be reversed
#s2: the string's length
#s3: flag that indicates if the string is of odd len
#s4: iterator left to right
#s5: iterator right to left
#s6: the string to be returned
# m4_define(INV_STACK, 4)
# m4_define(INV_UR, 7)
inversion:
    addi sp, sp, -BASE_STACK
    sw ra, RET_ADDR(sp)

    li t0, INV_UR
    sw t0, USED_REGISTERS(sp)
    call store_saved_registers
    addi sp, sp, -INV_STACK
    # prologue

    mv s1, a0
    mv s6, a0 #this if you want to invert the string in place
    # mv s6, a1 #this if you want to write the inverted string on a different destination  
    call strlen
    mv s2, a0
    li t0, 2
    blt s2, t0, end_inversion #if the string is of len <= 1 then it's already inverted
    li s4, 0
    addi s5, s2, -1
    andi s3, s2, 1 #strlen % 2
    swap_loop:
        add t0, s4, s3
        blt s5, t0, end_swap_loop #while (left + len % 2 < right)

        add t0, s1, s4
        add t1, s1, s5
        lb t0, 0(t0) #temp1 = str[left]
        lb t1, 0(t1) #temo2 = str[right]

        add t2, s6, s5
        add t3, s6, s4
        sb t0, 0(t2) #dest[right] = temp1
        sb t1, 0(t3) #dest[left] = temp2

        addi s4, s4, 1
        addi s5, s5, -1
        j swap_loop
    end_swap_loop:

    end_inversion: #end of the procedure, restores the stack and returns the inverted string
    mv a0, s6 #to return the string
    add t0, a0, s2
    sb x0, 0(t0) #null terminate
    
    addi sp, sp, INV_STACK
    call restore_saved_registers
    lw ra, RET_ADDR(sp)
    addi sp, sp, BASE_STACK
    ret




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
    addi sp, sp, -BASE_STACK
    sw ra, RET_ADDR(sp)
    
    mv a1, a0
    la a2, char_sanitizer
    call str_map

    
    lw ra, RET_ADDR(sp)
    addi sp, sp, BASE_STACK
    ret
    
    
    

#args:
#a0: plaintext, a1:cypher, a2: sostK, a3: blocKey, a4: dictionary function pointer a5: bool encrypt
#saved registers:
#s1: to encrypt
#s2: cypher dest
#s3: cypher
#s4: sostK
#s5: blockKey
#s6: dictionary function pointer
#s7: i to iterate over cypher
#s8: jump table address
#s9: i increment
#s10: iter_stop
#stack memory:  sp0 -> word[5] = {&case_a, ..., &case_e}
#               sp20 -> byte[201] buffer for writing the encrypted text

#cypher string is assumed to be properly formatted

#procedure iterates over the cypher string, at each cycle switching between 5 cases depending on each character
#in each case, one of the 5 defined encrypting procedures is called with its associated arguments

# encrypting procedure convention: a0: src_str, a1: dest_str, a2: encryption_key/dictionary_function
# m4_define(CYHPER_STACK, 204)
# m4_define(CYPHER_UR,  9)
cypher_iter:
    addi sp, sp, -BASE_STACK
    sw ra, RET_ADDR(sp)
    li t0, CYPHER_UR
    sw t0, USED_REGISTERS(sp)

    call store_saved_registers
    addi sp, sp, -CYHPER_STACK
    # stack management prologue



    mv s1, a0
    mv s2, sp  #char buffer of size 201 stored on the stack
    mv s3, a1
    mv s4, a2
    mv s5, a3  
    mv s6, a4 #storing arguments in saved registes: see above
    
    beq a5, x0, decypher_init # if (encrypt == false)

    cyhper_init:
    la s8, cypher_jump_table
    li s7, 0
    mv a0, s3
    li s9, 1 #increment = 1
    call strlen
    mv s10, a0


    j cypher_loop
    decypher_init:

    la s8, decypher_jump_table
    li s9, -1 # iterate backwards
    li s10, -1 #iterate until i >= 0
    mv a0, s3
    call strlen
    addi s7, a0, -1 #start from len - 1


    cypher_loop:

        add t0, s3, s7
        mv a0, s1 
        mv a1, s2 #loading src and dest for funtion call
        lb t0, 0(t0)

        cypher_switch:
        addi t0, t0, -A #temp = str[i] - 'A'
        slli t0, t0, 2 #temp *= 4
        add t0, s8, t0 #temp += &jump_table
        
        lw t0, 0(t0)   #dereference
        jr t0 # jump to (addresses [str[i] - 'A'])

        
        cypher_case_A:
            mv a2, s4 #loads sostk as argument
            call caesar
            j end_cypher_switch
        decypher_case_A:
            mv a2, s4
            call caesar_decypher
            j end_cypher_switch
        cypher_case_B:
            mv a2, s5 #loads blockKey as argument
            call block
            j end_cypher_switch
        decypher_case_B:
            mv a2, s5
            call block_decypher
            j end_cypher_switch
        cypher_case_C:
            call occurrence
            j end_cypher_switch
        decypher_case_C:
            call occurrence_decypher
            j end_cypher_switch
        cypher_case_D:
        decypher_case_D:
            mv a2, s6 #loads dictionary function as argument
            call dictionary
            j end_cypher_switch
        cypher_case_E:
        decypher_case_E:
            call inversion
            j end_cypher_switch
        end_cypher_switch:

        mv s2, s1
        mv s1, a0 #to encrypt = retval
        li a7, 4
        ecall # prints encrypted string
        la a0, newline
        li a7, 4
        ecall



        add s7, s7, s9 #i += increment
        bne s7, s10, cypher_loop #while(i != end)
    end_cypher_loop:

    
    # restoring stack and return epilogue
    addi sp, sp, CYHPER_STACK
    call restore_saved_registers
    lw ra, RET_ADDR(sp)
    addi sp, sp, BASE_STACK
    ret
