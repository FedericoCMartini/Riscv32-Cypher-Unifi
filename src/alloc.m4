

#design idea:
#the heap is divided in chunks, which all heave a header defining their size, and the pointer to the previous chunk header
# defined as such:
# word           word         word
#{ptr * prev, bool occupied, int size}

# best fit algorithm searches for the smallest free chunk and allocate it

# when the program runs out of memory call brk() to extend the memory of the program, return 0 in case of error
# request memory in increments of chunk_size, or multiples of chunk_size if more memory is requested
# keep track of program size in head_size

# size of ptr = word

# m4_define(C_PREV, 0)
# m4_define(C_OCCUPIED, 4)
# m4_define(C_SIZE, 8)

# m4_define(C_HEAD_SIZE, 12)

# m4_define(MIN_HEAP, 1024)
# m4_define(MIN_REQUEST, 1024)

.data
m4_ifdef(`COMBINE', `', `
    test_str1: .string "0123456789ABCDE"
    test_str2: .string "Abc"
    test_str3: .string "pollo"
    test_str4: .byte 0 #""
    test_str5: .string "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas dignissim metus ut nibh aliquet sagittis. Cras porta cursus diam, in maximus metus imperdiet vel. Nulla id justo sit amet nunc egestas scelerisque. Donec urna ex, cursus non tellus eu, suscipit vestibulum urna. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum ornare ex quis aliquet maximus. Praesent efficitur faucibus erat in elementum. Aliquam vel iaculis nisi, vel varius erat. Nunc ac. "
    n_test_strings: .word 5 # ')
    malloc_stack_size: .word 16
    heap_size: .word 0
    max_chunk_size: .word 0x10000000
    request_size: .word 0
    starting_request_size: .word MIN_REQUEST
    min_heap_size: .word MIN_HEAP
    last_chunk: .word 0

.text

m4_ifdef(`COMBINE', `.global malloc', `.global _start') 
m4_ifdef(`COMBINE', `.global free')
# m4_ifdef(`COMBINE', `', `m4_define(N_tests, 5)')
# /* '*/ #needed for m4 and correct text highlighting on vscode

m4_ifdef(`COMBINE', `', `_start:

    
    li s1, 0
    li s2, N_tests

    lw t1, n_test_strings
    add t0, t1, s2 #n_str + n_tests
    slli t0, t0, 2 #(N_tests + n_test_strings) * 4 
    sub sp, sp, t0


    
    la t1, test_str1
    la t2, test_str2
    la t3, test_str3
    la t4, test_str4
    la t5, test_str5

    sw t1, m4_eval(N_tests * 4) (sp)
    sw t2, m4_eval((N_tests + 1)* 4) (sp)
    sw t3, m4_eval((N_tests + 2)* 4) (sp)
    sw t4, m4_eval((N_tests + 3)* 4) (sp)
    sw t5, m4_eval((N_tests + 4)* 4) (sp)
    
    .data
        repeat_loop: .word 1
        test_str_offset: .word 7
.text 

    malloc_loop:
        
        lw t0, n_test_strings
        lw t1, test_str_offset
        lw t2, repeat_loop
        mul t1, t1, t2
        add t1, t1, s1
        rem t0, t1, t0
        
        slli t0, t0, 2
        add a0, sp, t0
        lw a0, m4_eval(N_tests * 4) (a0)

        call malloc_test_print_str
        
        slli t0, s1, 2
        add t0, sp, t0
        sw a0, 0(t0)

        addi s1, s1, 1
        blt s1, s2, malloc_loop
    

    lw t0, repeat_loop
    beq x0, t0, exit

    la t0, repeat_loop
    sw x0, 0(t0)
    li s5, N_tests
    li s1, 0

    .data
        free_prologue: .string "\nTrying to free str:"

.text
    free_loop:

        slli t0, s1, 2 #i * 4
        add s4, sp, t0 #i * 4 + stack
        lw a0, 0(s4)  #*str[i]

        la a1, free_prologue
        li a2, 404
        call log_str
    
        lw a0, 0(s4)

        call free

        addi s1, s1, 1
        blt s1, s2, free_loop

    li s5, N_tests
    li s1, 0

    j malloc_loop
exit:
    li a0, 0
    li a7, 10
    ecall #exit
    

    .data
    test_str_prompt: .string "\nTesting duplicating src str:"
    newline: .string "\n"
    fail_str: .string "error: malloc failed\n"
    newline_indent: .byte 10, 11, 0
.text
malloc_test_print_str:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw a0, 4(sp)
    
    #get input length
    call strlen
    sw a0, 8(sp)


    #log input string with address and length
    lw a0, 4(sp)
    la a1, test_str_prompt
    lw a2, 8(sp)
    call log_str #log_str(str, "Testing...", len)

   
    #malloc call with input_size + 1
    lw a0, 8(sp)
    addi a0, a0, 1
    call malloc

    beq a0, x0, on_fail
    
    #store malloc address on stack
    sw a0, 12(sp)

    .data
        malloc_str: .string "Malloc return "
    .text
    la a1, malloc_str
    #lw a0, 12(sp)
    call log_addr #log returned address

    #copy src str into address
    lw a0, 4(sp) #src
    lw a1, 12(sp) #dest
    lw a2, 8(sp) #len
    call strncpy


    .data 
        test_str_copy: .string "Copy:"
.text
    #log copied string with address and length
    lw a0, 12(sp)
    la a1, test_str_copy
    lw a2, 8(sp)
    call log_str

    #load duplicated string from stack
    lw a0, 12(sp)

    lw ra, 0(sp)
    addi sp, sp, 16
    ret
')

#a0: src, #a1: dest #a2: len
strncpy:
    li t0, 0
    blt a2, x0, strncpy_end
    beq x0, a2, strncpy_terminate

    strncpy_loop:
        add t1, t0, a0
        lb t2, 0(t1) #c = src[i]

        add t3, t0, a1
        sb t2, 0(t3) #dest = src[i]
        addi t0, t0, 1
        blt t0, a2, strncpy_loop 

    strncpy_terminate:
    
    add t3, a1, t0
    sb x0, 0(t3)

    strncpy_end:
    mv a0, a1
    ret

m4_ifdef(`DEBUG', `

#a0: addr #a1: message
log_addr:
    addi sp, sp, -8
    sw ra, 0(sp)

    sw a0, 4(sp)

    beq a1, x0, log_addr_raw

    mv a0, a1
    li a7, 4
    ecall

    log_addr_raw:

    .data
        log_addr_str: .string "Address: "
.text    
    la a0, log_addr_str

    li a7, 4
    ecall #printstr(log_addr_str)

    lw a0, 4(sp)
    li a7, 34 #print hex
    ecall 

    call print_newline

    lw ra, 0(sp)
    addi sp, sp, 8
    ret

print_newline:
    addi sp, sp, -4
    sw ra, 0(sp)

    li a0, 10 #\n
    li a7, 11 #printchar
    ecall #putchar(\n)

    lw ra, 0(sp)
    addi sp, sp, 4
    ret
')

m4_ifdef(`COMBINE', `', `
#a0: str #a1 message #a2: len
log_str:
    addi sp, sp, -4
    sw ra, 0(sp)

    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)

    bge x0, a2, log_str_with_len #if (len < 0) len = strlen(str)

    call strlen

    mv a2, a0
    log_str_with_len:
    sw a2, 8(sp)

    lw a0, 4(sp)
    li a7, 4 #print str
    ecall #printstr(message)

    call print_newline


    lw a0, 0(sp) #print string
    li a7, 4
    ecall

    .data
        log_str_size: .byte 10, 11
        .string "Size: "  #\t string literal is not accepted so i have to write in in as a byte value preceding the char array

.text
    la a0, log_str_size
    li a7, 4 #printstr("Size: ")
    ecall

    lw a0, 8(sp)
    li a7, 1 #printnumber(size)
    ecall

    lw a0, 0(sp)
    la a1, newline_indent
    call log_addr

    addi sp, sp, 12

    lw ra, 0(sp)
    addi sp, sp, 4

    ret

    
strlen:
    mv t0, a0
    li a0, 0
    beq t0, x0, strlen_end
strlen_loop:
    add t1, a0, t0
    lb t2, 0(t1)
    beq x0, t2, strlen_end
    addi a0, a0, 1
    j strlen_loop
    
strlen_end:
    ret
    
on_fail:
    la a0, fail_str
    li a7, 4
    
    j exit ')
        
#a0: request_size
#s1: heap_start
#s2: current chunk
#s3: &best_fit
#s4: heap_outer_bound
#s5: prev
best_fit_chunk_search:
#    find_chunk:
    addi sp, sp, -8
    sw ra, 4(sp)

    addi sp, sp, -20
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)

    li s0, 28
    ##...
    
    la s1, heap_start #pointer to start of the heap
    mv s2, s1  #it's gonna be used as the pointer to the current chunk
    li s3, 0 #address of the smallest compatible free chunk
    lw s4, last_chunk
    # lw a0, 4(sp) #loads requested_bytes
    
    bge s2, s4, end_chunk_search #current chunk >= last_chunk

    chunk_search: #while loop, loops over whole heap
    
        lw t0, C_OCCUPIED (s2)
        lw t1, C_SIZE (s2) #loads current.size
        m4_ifdef(`DEBUG', `
        andi t2, t1, 0b11 #size % 4
        slt t2, x0, t2 #size % 4 != 0
        li t3, 1
        sltu t3, t3, t0 #(1 < occupied)->value isnt in range
        or t2, t3, t2
        lw t3, C_PREV (s2)
        xor t3, s5, t3 #zero if equal
        mul t3, s5, t3 #if prev == null then ignores 
        or t2, t3, t2 #size % 4 != 0 occupied != 1 and 0, current.prev != prev
        bne x0, t2, search_chunk_error

        ')
        sltu t6, x0, t0 #(chunk.occupied != 0)
        
        slt t5, t1, a0 #(current.size < requested_bytes)
        or t6, t6, t5
        bne t6, x0, next_chunk #if (!current.occupied || current.size < request_size) skip
        
        beq s3, x0, select_chunk #if smallest == null 
        
        lw t6, C_SIZE (s3) #loads size of smallest        
        bge t1, t6, next_chunk #if (current.size >= smallest.size) skip
        
        select_chunk: #smallest_free_chunk = current_chunk
            mv s3, s2
    
        next_chunk:
        lw t6, C_SIZE (s2) #current.size
        add s2, s2, t6 # current_chunk += current.chunk_size
        addi s2, s2, C_HEAD_SIZE # current_chunk += chunk_header_size
    
        blt s2, s4, chunk_search #current chunk >= last_chunk
    
    
    end_chunk_search:
    
    # bne x0, s3, allocate_chunk
    mv a0, s3


    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)

    addi sp, sp, 20
    lw ra, 4(sp)
    addi sp, sp, 8
    ret

#ret_val: a0: best_fit

m4_ifdef(`DEBUG', `
.data
            malformed_chunk: .string "Error: Malformed chunk at "
            chunk_attr_pre: .string "{ prev: "
            chunk_attr_mid: .string ", occupied: "
            chunk_attr_last: .string ", size: "
            chunk_attr_post: .string " }"
        .text


    #a0: chunk, #a1: msg
    log_chunk: 
    
    addi sp, sp, -8
    sw ra, 0(sp)
    sw a0, 4(sp)

    call log_addr

    lw a0, 4(sp)

    call chunk_tostr

    li a7, 11
    li a0, 10
    ecall #print "\n"

    lw ra, 0(sp)
    addi sp, sp, 8
     
    ret


    search_chunk_error:
        
    mv a0, s2
    la a1, malformed_chunk
    call log_chunk

    li a7, 10
    li a0, 1
    ecall #exit
')

#a0: size
fit_request_chunk_size:
    addi a0, a0, C_HEAD_SIZE #adding header_size to request_body
    la t1, request_size
    lw t0, 0(t1)

    blt a0, t0, chunk_size_fits_request_size #size < request_size
increase_request_chunk_size: #while loop that increases the size of a request
    slli t0, t0, 1 # request size <<= 1
    sw t0, 0(t1)
    blt t0, a0, increase_request_chunk_size
    
    chunk_size_fits_request_size:
    ret

m4_ifdef(`DEBUG', `.data
    new_chunk_str: .byte 10, 11
    .string "New chunk made at " 
    freed_chunk:  .byte 10, 11 
    .string "Chunk freed at " 
    .text')
    
#a0: last_chunk, a1: new_chunk_size, a2: available_memory
new_chunk:
    addi sp, sp, -12
    sw ra, 0(sp)

    andi a2, a2, -4 #4 aligns available memory by shrinking

    andi t0, a1, 0b11
    beq x0, t0, four_aligned_chunk_size
    
    _align_requested_size:
        
        addi sp, sp, -4
        sw a0, 0(sp)
        mv a0, a1
        call four_align_size
        mv a1, a0
        lw a0, 0(sp)
        addi sp, sp, 4
        lw a2, 8(sp)

    four_aligned_chunk_size:
    
    addi a2, a2, -C_HEAD_SIZE #available_memory -= size_of_header

    bne a1, x0, set_chunk_size
    use_all_available:
    mv a1, a2 #size = available_memory - size_of_header
    slti t0, a2, 1 #available_memory <= 0
    add a1, a1, t0 #size += available_memory == 0 -> set to trigger subsequent check
    set_chunk_size:

    bge a2, a1, calc_new_address #available_memory >= size 

    new_chunk_fail:
        li a0, 0
        j new_chunk_end
    
    calc_new_address:
    beq x0, a0, no_prev

    lw t1, C_SIZE (a0) #prev.size

    mv t0, a0 # STORE PREV IN T0
    
    add a0, a0, t1 # prev += prev.size
    addi a0, a0, C_HEAD_SIZE # new = prev + prev.size + header_size
    j set_new_chunks_prev

    no_prev:
    la a0, heap_start #new = heap_start
    mv t0, x0

    set_new_chunks_prev:
    sw a0, 4(sp)
    sw t0, C_PREV (a0) #new.prev = prev

    set_new_chunks_size:

    
    sw a2, C_SIZE (a0) #new.size = available_memory
    sw x0, C_OCCUPIED (a0) #new.occupied = false

    sub a2, a2, a1 #available_memory -= size
    
    li t0, 4 #min_size
    addi t0, t0, C_HEAD_SIZE
    blt a2, t0, check_chunk_after_new #available_memory < header_size + min_size

    new_chunk_with_leftover_memory:
        sw a1, C_SIZE (a0) #new.size = size

        mv a1, x0
        call new_chunk #(current_chunk, 0, available_size - size)
        j new_chunk_return

    check_chunk_after_new:
        lw t1, last_chunk
        bge a0, t1, nc_update_last_chunk 
        update_next_link: #if chunk < last_chunk
            lw t0, C_SIZE (a0)
            add t0, t0, a0 #current + size
            addi t0, t0, C_HEAD_SIZE #next = current.size + sizeof header
            sw a0, C_PREV (t0) #next.prev = current 

            j nc_check_after_endif
        nc_update_last_chunk: #else
            la t1, last_chunk
            sw a0, 0(t1)
        
        nc_check_after_endif:

    new_chunk_return:
    lw a0, 4(sp)
    new_chunk_end:m4_ifdef(`DEBUG',`
    
    la a1, new_chunk_str
    call log_chunk
    lw a0, 4(sp)')
    
    lw ra, 0(sp)
    addi sp, sp, 12
    ret
#return: #a0: new chunk


#a0: chunk #a1: reduced_size
split_chunk:
    lw t0, C_OCCUPIED (a0)
    beq x0, t0, split_free_chunk #cannot split occupied chunks
        failed_split:
        li a0, 0
        j split_chunk_end
    
    split_free_chunk:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw a0, 4(sp)
    m4_ifdef(`DEBUG',`
    
    .data
    split_msg: .string "Splitting chunk at "
.text

    addi sp, sp, -4
    sw a1, 0(sp)
    la a1, split_msg
    call log_chunk
    lw a1, 0(sp)
    addi sp, sp, 4
    lw a0, 4(sp)

    ')
    lw t2, C_SIZE (a0) #chosen_chunk.size
    sub t3, t2, a1 #leftover memory = chosen.size - target_size
    
    lw a2, C_SIZE (a0) #available_memory = chunk.size
#    sw a1, C_SIZE (a0) #chunk.size = target_size

    lw a0, C_PREV (a0) #chunk.prev
    
    addi a2, a2, C_HEAD_SIZE
    resize_left:
    call new_chunk #(chunk.prev, target_size, previous_chunk_size)
    #tries to create a new chunk after the previous one, nothing happens if not enough memory is available
    
    lw a0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 8
    split_chunk_end:
    ret    
#return : original_chunk / 0 on a fail

#if not already, expands requests size to the next multiple of 4
four_align_size:
    andi t0, a0, -4   # size - size % 4
    slt t1, t0, a0      # size % 4 > 0
    slli t1, t1, 2      # s%4!=0 <<2 # (4 % 0 != 0)? 4 : 0
    add a0, t0, t1      # size = (size - size % 4 + 4 * (size % 4 != 0))
    ret

#a0 is the size required, returns address of allocated memory, 0 on fail
malloc:
    ble a0, x0, failed_malloc
    lw t0, malloc_stack_size
    sub sp, sp, t0
    sw ra, 0(sp)
    
    ble a0, x0, failed_malloc
    lw t0, max_chunk_size
    blt t0, a0, failed_malloc #checks if size is (0 < x < max_size)
    
    call four_align_size
    sw a0, 4(sp)

    call fit_request_chunk_size 
    call heap_initialize

    lw a0, 4(sp)
    call best_fit_chunk_search
    
    
    bne x0, a0, allocate_chunk
                                #if best_fit(size) == null
    call request_memory          #request_memory(last_chunk)
    
    beq a0, x0, failed_malloc


allocate_chunk: 
    sw a0, 12(sp) #save chunk
    lw a1, 4(sp) #request_size
    call split_chunk
 
return_chunk: 
    lw a0, 12(sp) #chosen_chunk
    li t0, 1
    sw t0, C_OCCUPIED (a0) #chunk.occupied = true
    addi a0, a0, C_HEAD_SIZE #offsets pointer from header to usable memory
    j malloc_return
    
 
failed_malloc:
    li a0, 0

malloc_return:
    m4_ifdef(`DEBUG', `
    addi sp, sp, -4
    sw a0, 0(sp)
    call print_heap
    lw a0, 0(sp)
    addi sp, sp, 4
    ')
    lw ra, 0(sp)
    lw t0, malloc_stack_size
    add sp, sp, t0
    
    ret
#end to malloc
    

    
    
heap_initialize:
    lw t0, heap_size
    bne t0, x0, heap_is_initialized # if (last_chunk != 0) return;
    
    addi sp, sp, -4
    sw ra, 0(sp)
    
    lw a0, starting_request_size
    call four_align_size # += (min_req_size % 4 != 0)? 4 - min_req_size % 4 : 0

    la t1, starting_request_size
    la t0, request_size
    sw a0, 0(t1) #min_req_size = four_align(min_req)
    sw a0, 0(t0) #req_size = min_req_size
    

    lw a0, min_heap_size
    call four_align_size # += (min_heap_size % 4 != 0)? 4 - min_heap_size % 4 : 0

    la t1, min_heap_size
    la t0, heap_size
    sw a0, 0(t1) #min_heap_size = four_align(min_heap)
    sw a0, 0(t0) #heap_size = min_heap_size
    
    mv a2, a0
    
    mv a0, x0
    mv a1, x0
    call new_chunk

    la t0, last_chunk
    sw a0, 0(t0)

    lw ra, 0(sp)
    addi sp, sp, 4
    
heap_is_initialized: 
    ret   
    

#a0: chunk_1, #a1: chunk_2
merge_chunks:
    blt a0, a1, not_swap_mc #we always want the chunk first in memory as a0
    
    xor a1, a0, a1 
    xor a0, a0, a1
    xor a1, a0, a1 #swap
    
    not_swap_mc:
    la t5, heap_start
    lw t6, last_chunk

    slt t0, a0, t5 #left < heap_start
    slt t1, t6, a1 #last_chunk < right
    or t0, t0, t1 #(left < heap_start || heap_end < right) 
    bne t0, x0, failed_merge #a0 points to before the heap or a1 points to after the heap

    lw t0, C_OCCUPIED (a0) #left_chunk.occupied
    lw t1, C_OCCUPIED (a1) #right_chunk.occupied
    lw t2, C_PREV (a1) #right_chunk.prev
    slt t2, a0, t2 #left_chunk < right_chunk.prev 
    #here i need to check if left == right_chunk
    #but since left comes beore than right it cannot be > right.prev
    
    or t4, t0, t1
    or t4, t2, t4
    beq x0, t4, proceed_to_merge 
            # if (#not contiguous chunks / occupied chunks) return null
        failed_merge:
        li a0, 0
        ret

    proceed_to_merge:

    m4_ifdef(`DEBUG', `
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw ra, 8(sp)
    call log_pre_merge
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 12
    ')

    lw t1, C_SIZE (a1) #right.size
    sw x0, C_PREV (a1) #####
    sw x0, C_OCCUPIED (a1) # wipe right chunk
    sw x0, C_SIZE (a1) #####

    add t5, t1, a1 #right + right_size
    addi t5, t5, C_HEAD_SIZE #right.next = right + right_size + header_size

    #possibly test if right == right.next.prev?
    ble t6, t5, mc_update_last_chunk # (last_chunk <= right.next)
    link_next_chunk:

        sw a0, C_PREV (t5) #right.next.prev = left
        j mc_endif
    mc_update_last_chunk:

        la t0, last_chunk
        sw a0, 0(t0)

    mc_endif:
    
    lw t2, C_SIZE (a0) #left.size 
    addi t0, t1, C_HEAD_SIZE #header_size + right_size
    add t0, t0, t2 #left.size + header_size + right.size

    sw t0, C_SIZE (a0) #left.size += right.size + header_size
    m4_ifdef(`DEBUG', `
    addi sp, sp, -8
    sw a0, 0(sp)
    sw ra, 4(sp)
    .data
        post_merge_msg: .string "Merge result "
.text
    la a1, post_merge_msg
    call log_chunk
    
    lw ra, 4(sp)
    lw a0, 0(sp)
    addi sp, sp, 8')
    merge_return:
        
    ret
#return: a0 merged_chunk/null on fail


m4_ifdef(`DEBUG', `
    chunk_tostr:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw a0, 4(sp)
    

    li a7, 4
    la a0, chunk_attr_pre
    ecall

    lw t0, 4(sp)

    lw a0, C_PREV (t0)
    li a7, 34 
    ecall

    li a7, 4
    la a0, chunk_attr_mid
    ecall

    lw t0, 4(sp)

    lw a0, C_OCCUPIED (t0)
    li a7, 1
    ecall

    li a7, 4
    la a0, chunk_attr_last
    ecall
    
    lw t0, 4(sp)
    
    lw a0, C_SIZE (t0)
    li a7, 1
    ecall

    li a7, 4
    la a0, chunk_attr_post
    ecall

    addi sp, sp, 8
    ret

    .data
        merge_pre: .string "Trying to merge "
        merge_mid: .string " with "
.text
    #a0: left, a1: right
    log_pre_merge:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)

    la a0, merge_pre
    li a7, 4
    ecall

    lw a0, 4(sp)
    li a7, 34 #print hex
    ecall

    la a0, merge_mid
    li a7, 4
    ecall

    lw a0, 8(sp)
    li a7, 34
    ecall

    li a0, 10
    li a7, 11
    ecall #"\n"

    lw a0, 4(sp)
    call chunk_tostr

    lw a0, 8(sp)
    call chunk_tostr

    li a0, 10
    li a7, 11
    ecall #"\n"

    lw ra, 0(sp)
    addi sp, sp, 12
    ret
')
    
#a0: last_chunk, a1: request_size  
make_newly_requested_memory_chunk:
    # lw t0, 4(sp) #last chunk

    lw t1, C_SIZE (a0) #last_chunk.size
    addi t3, t1, C_HEAD_SIZE # last_chunk.size + header_size
    
    add t1, t3, t0 # &last_chunk + header_size + last_chunk.size
    sw t0, C_PREV (t1) #new_chunk.prev = last_chunk
    sw x0, C_OCCUPIED (t1) #new_chunk.occupied = false
    
    la t4, heap_start
    sub t5, t1, t4 #next_chunk - &heap
    addi t5, t5, C_HEAD_SIZE #next_chunk - &heap - header_size
    sw t5, C_SIZE (t1) #new_chunk.size = &new_chunk - &heap_start - header_size
    ret

request_memory: 
    addi sp, sp, -12
    sw ra, 0(sp)
    sw a0, 4(sp)

    lw a0, last_chunk    
    lw t1, request_size
    lw t2, heap_size

    add t0, t2, t1 #new_heap_size = heap_size + request_size
    
    sw t0, 8(sp) #store new size

    set_new_program_break:
    la t1, heap_start
    add a0, t1, t0 #heap start + new_heap_size

    li a7, 214 #brk syscall
    
    ecall
    
    li t0, -1
    beq a0, t0, brk_fail
    
    extend_heap:
    la t0, heap_size
    lw t1, 8(sp)
    sw t1, 0(t0) #heap_size = new_heap_size

    lw a0, 4(sp) #last_chunk
    lw t0, C_OCCUPIED (a0) # last.occupied
    beq x0, t0, extend_last_chunk #if !last_chunk.occupied
    create_new_chunk:
    # lw a0, 4(sp) #last_chunk
    mv a1, x0
    lw a2, request_size # how much the program memory was extended
    call new_chunk #new chunk(last, 0, request_size)
        
    j request_memory_return
    
extend_last_chunk:    
    lw a0, 4(sp) #last chunk
    lw t1, C_SIZE (a0) #last chunk.size
    lw t2, request_size# requested bytes
    
    add t1, t1, t2
    sw t1, C_SIZE (a0) #chunk_size += requested_bytes
    j request_memory_return
    
brk_fail:
    li a0, 0
    
request_memory_return:
    la t0, last_chunk
    sw a0, 0(t0) #last_chunk = last

    lw ra, 0(sp)
    addi sp, sp, 12
    ret
    
    
m4_ifdef(`DEBUG', `
print_heap:
    addi sp, sp, -4
    sw ra, 0(sp)
    addi sp, sp, -20
    sw s1, 0(sp)
    sw s2, 4(sp)
    sw s3, 8(sp)
    sw s4, 12(sp)
    sw s5, 16(sp)
    addi sp, sp, -104


    la s1, heap_start
    lw s2, heap_size
    add s2, s2, s1
    
    li s4, 0
    li s5, 100
    mv s3, s1
    print_heap_loop:
        lw t0, C_OCCUPIED (s3)

        li t1, -11
        mul t0, t0, t1
        addi t0, t0, 46 #defines char that represents the chunk

        lw t1, C_SIZE (s3)
        mul t1, t1, s5 #current.size * 100
        sub t5, s2, s1 #heap_size
        div t1, t1, t5 #current.size * 100 / heap_size


        li t5, 2
        blt t1, t5, p_chunk_divider
        big_chunk_notation:
            add t6, sp, s4
            sb t0, 0(t6)

            addi s4, s4, 1
            addi t1, t1, -1
            bgt t1, x0, big_chunk_notation
        p_chunk_divider: 
        add t6, sp, s4
        li t0, 47
        sb t0, 0(t6)
        addi s4, s4, 1

        print_chunk:
        mv a0, s3
        call chunk_tostr

        lw t0, C_SIZE (s3)
        addi t0, t0, C_HEAD_SIZE
        add s3, s3, t0

        blt s3, s2, print_heap_loop

    li a0, 10
    li a7, 11
    ecall
    add t6, sp, s4
    sb x0, 0(t6)
    mv a0, sp
    li a7, 4
    ecall
    li a0, 10
    li a7, 11
    ecall


    addi sp, sp, 104
    lw s1, 0(sp)
    lw s2, 4(sp)
    lw s3, 8(sp)
    lw s4, 12(sp)
    lw s5, 16(sp)
    addi sp, sp, 20
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
    ')


#a0: mem_addr
free:
    addi sp, sp, -8
    sw ra, 0(sp)

    la t0, heap_start
    lw t1, heap_size

    add t1, t1, t0 #heap_end
    slt t6, a0, t0 #mem_addr < heap_start
    slt t5, t1, a0 #heap_end < mem_addr

    or t6, t5, t6 #
    bne x0, t6, out_of_range_free


    lw t6, C_SIZE (t0) #first_chunk.size
    add t6, t0, t6 #first_chunk.size + &first_chunk
    addi t6, t6, C_HEAD_SIZE #next_chunk = current + size + header_size

    blt a0, t6, chunk_match #mem_addr < next_chunk
    match_mem_addr:
        mv t0, t6       #current = next
        lw t6, C_SIZE (t0)    #current.size
        add t6, t0, t6  #size + &current
        addi t6, t6, C_HEAD_SIZE  #next_chunk = &current + size + header_size

        slt t2, t0, a0    #current < mem_addr
        slt t3, a0, t6    #mem_addr < next
        and t3, t3, t2    #current < mem_addr < next
        beq x0, t3, match_mem_addr

    chunk_match:
    
    m4_ifdef(`DEBUG', `
    .data
        free_chunk_prompt: .string "Trying to free chunk at "
    .text
    sw t0, 4(sp)
    mv a0, t0
    la a1, free_chunk_prompt
    call log_chunk
    lw t0, 4(sp)

    ')
    lw t1, C_OCCUPIED (t0)
    beq x0, t1, double_free #current.occupied == 0
    
    sw x0, C_OCCUPIED (t0) #current.occupied = 0
    sw t0, 4(sp)
    
    merge_left:
    mv a1, t0
    lw a0, C_PREV (a1) #prev
    call merge_chunks


    bne x0, a0, merge_right
    lw a0, 4(sp)

    merge_right:
    lw t0, last_chunk
    beq t0, a0, shrink_heap

    lw t0, C_SIZE (a0)
    addi a1, a0, C_HEAD_SIZE
    add a1, a1, t0
    call merge_chunks

     m4_ifdef(`DEBUG', `
    
    lw a0, 4(sp)
    la a1, freed_chunk
    call log_chunk')

      m4_ifdef(`DEBUG', `
    addi sp, sp, -4
    sw a0, 0(sp)
    call print_heap
    lw a0, 0(sp)
    addi sp, sp, 4
    ')

    lw t0, last_chunk
    bne t0, a0, free_end
    check_shrink_heap: #if chunk == last_chunk
       call shrink_heap

    free_end:

    lw ra, 0(sp)
    addi sp, sp, 8 

    ret
    
    out_of_range_free:
        .data 
        oor_free: .string "Out of range free\n"
        .text
        li a7, 64 #write
        li a0, 2 #stderr 
        la a1, oor_free
        li a2, 18 #write (2, "Out of range free\n", 19);
        ecall
        
        j exit
        
    double_free:
        .data
         double_free_str: .string "Double free\n"
        .text
        li a7, 64 #write
        li a0, 2 #stderr 
        la a1, double_free_str
        li a2, 18 #write (2, "Out of range free\n", 19);
        ecall
        j exit

# m4_define(`SHRINK_H_STACK', 16)
# m4_define(`SH_LAST', 4)
# m4_define(`SH_LAST_SIZE', 8)
# m4_define(`SH_NEW_BREAK', 12)
shrink_heap:
    addi sp, sp, -SHRINK_H_STACK
    sw ra, 0(sp)

    lw t5, heap_size
    lw t6, min_heap_size

    ble t5, t6, shrink_heap_return #no need to shrink if (size <= min_heap_size) 

    lw a0, last_chunk #chunk = last_chunk
    lw t4, heap_start
    sub t3, a0, t4 #size_without = last_chunk - heap_start

    ble t3, t6, shrink_to_min
    shrink_to_request: #if (size_without_last > min_heap_size)
        lw t1, C_SIZE (a0) #last.size
        lw t0, request_size
        addi t1, t1, C_HEAD_SIZE #last.size + header_size
        blt t1, t0, shrink_heap_return #if (chunk.size + header_size < request_size) return

        rem a0, t1, t0 #(last.size + header_size) % request_size
        call calc_last_chunk_after_shrink #(shrink last by removing n * request_size)
        
    j shrink_heap_endif
    shrink_to_min: #else
        sub a0, t6, t3

        call calc_last_chunk_after_shrink #(min_heap_size - size_without)

    # j shrink_heap_endif
    shrink_heap_endif:

    sw a0, SH_LAST (sp)
    sw a1, SH_LAST_SIZE (sp)

    addi a0, a0, C_HEAD_SIZE
    add a0, a0, a1 #last + last.size + header_size

    sw a0, SH_NEW_BREAK (sp)

    li a7, 214 #brk syscall
    
    ecall

    blt a0, x0, shrink_heap_return #if (brk(new_break) < 0) return


    la t0, last_chunk
    lw a0, SH_LAST (sp)
    lw a1, SH_LAST_SIZE (sp)
    sw a0, 0(t0) #last_chunk = chunk
    sw a1, C_SIZE (a0) #last_chunk.size = shrinked_size

    la t0, heap_size
    la t1, heap_start
    lw t2, SH_NEW_BREAK (sp)
    sub a0, t2, t1 #new_size = new_break - heap_start

    sw a0, 0(t0) #heap_size = new_size

    lw t0, min_heap_size
    blt t0, a0, shrink_heap_return
    reset_request_size: #if (heap_size == min_size)
        la t0, request_size
        lw t1, starting_request_size
        sw t1, 0(t0) #request_size = starting_reqiest 

    shrink_heap_return:
    lw ra, 0(sp)
    addi sp, sp, SHRINK_H_STACK
    ret


# calculates how to reduce the last heap chunk to fit the given size
# returns the node which will be set at as the last, and its size
# if (size <= header_size) then the second to last chunk is returned with header_size - size bytes of padding
# a0: size
calc_last_chunk_after_shrink:
    mv t6, a0
    lw a0, last_chunk

    li t0, C_HEAD_SIZE
    bgt a1, t0, shrink_to_fit_no_delete
    delete_current_and_pad_prev:
        lw a0, C_PREV (a0) #chunk = chunk.prev 
        lw t2, C_SIZE (a0) #chunk.size
        add a1, t2, t6 #chunk.size +=size
        
        ret

    shrink_to_fit_no_delete:
        lw a1, C_SIZE (a0) #chunk.size

        addi t2, a1, -C_HEAD_SIZE #size - header_size

        blt t1, t2, shrink_ret #if chunk.size < size - header_size -> return

        mv a1, t2 #chunk.size = size - header_size
        shrink_ret:
        ret
#return a0: last chunk, a1: new size

.bss
    .align 2
    heap_start: .zero MIN_HEAP #should be last
