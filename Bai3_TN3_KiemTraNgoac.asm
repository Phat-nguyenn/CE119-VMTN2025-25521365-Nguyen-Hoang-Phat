###############################################################################
# CE119 - Lab 02 - TN3 - Kiem tra ngoac can bang bang ngan xep: check_brackets
# Sinh vien: Nguyen Hoang Phat - MSSV 25521365 - Lop VMTN2025
# d = 5, k = 8, S = {0,8,2,3,7,10,1,7,0,3,9,8} - MARS 4.5
###############################################################################
        .data
b1:         .asciiz "(a+b)*[c-{d/e}]"
b2:         .asciiz "f(x[i]{j}))"
b3:         .asciiz "{[(])}"
b4:         .asciiz "((a)"
b5:         .asciiz ""
b6:         .asciiz "no brackets here"
b7:         .asciiz "]"
b8:         .asciiz "([)]"
bP:         .asciiz "([{([{([])}])}])"     # chuoi ca nhan P: k = 8 cap long nhau
            .align 2
bstrs:      .word b1, b2, b3, b4, b5, b6, b7, b8, bP
nbstrs:     .word 9
s_set:      .asciiz "Bo "
s_colon:    .asciiz ": ($v0, $v1) = ("
s_comma:    .asciiz ", "
s_close:    .asciiz ")\n"

        .text
        .globl main
# main: $s3 = con tro bang chuoi, $s4 = so chuoi con lai, $s2 = so thu tu
main:
        la      $s3, bstrs
        lw      $s4, nbstrs
        li      $s2, 1
m_loop:
        beq     $s4, $zero, m_exit
        lw      $a0, 0($s3)
        jal     check_brackets
        move    $t0, $v0                # vi tri
        move    $t1, $v1                # ma loi
        la      $a0, s_set
        li      $v0, 4
        syscall
        li      $t2, 9
        beq     $s2, $t2, m_printP
        move    $a0, $s2
        li      $v0, 1
        syscall
        j       m_name_done
m_printP:
        li      $a0, 'P'
        li      $v0, 11
        syscall
m_name_done:
        la      $a0, s_colon
        li      $v0, 4
        syscall
        move    $a0, $t0
        li      $v0, 1
        syscall
        la      $a0, s_comma
        li      $v0, 4
        syscall
        move    $a0, $t1
        li      $v0, 1
        syscall
        la      $a0, s_close
        li      $v0, 4
        syscall
        addi    $s3, $s3, 4
        addi    $s4, $s4, -1
        addi    $s2, $s2, 1
        j       m_loop
m_exit:
        li      $v0, 10
        syscall

###############################################################################
# check_brackets: kiem tra cac cap ngoac ( ) [ ] { } trong chuoi .asciiz
#   Tham so : $a0 = dia chi chuoi
#   Tra ve  : $v0 = vi tri (dem tu 1), $v1 = ma loi
#             0: hop le (v0 = 0); 1: ngoac dong khac loai ngoac mo o dinh;
#             2: ngoac dong khi ngan xep rong; 3: het chuoi con ngoac mo
#             (v0 = do dai + 1)
#   Ngan xep: dung $sp, moi phan tu 1 word chua ma ASCII cua ngoac mo.
#   Thanh ghi su dung: $a0 (bi thay doi), $t0..$t3, $t9, $v0, $v1
#   $t9 = $sp luc vao thu tuc: dung de nhan biet ngan xep rong
#   ($sp == $t9) va khoi phuc $sp tai MOI loi ra (cb_ret).
#   Thu tuc la.
###############################################################################
check_brackets:
        move    $t9, $sp                # ghi nho day ngan xep
        li      $t0, 0                  # $t0 = vi tri ky tu hien tai
cb_loop:
        lbu     $t1, 0($a0)             # c = ky tu
        beq     $t1, $zero, cb_end      # het chuoi
        addi    $t0, $t0, 1
        addi    $a0, $a0, 1

        # ---- ngoac mo: push ----
        li      $t2, '('
        beq     $t1, $t2, cb_push
        li      $t2, '['
        beq     $t1, $t2, cb_push
        li      $t2, '{'
        beq     $t1, $t2, cb_push

        # ---- ngoac dong: $t3 = ngoac mo tuong ung ----
        li      $t3, '('
        li      $t2, ')'
        beq     $t1, $t2, cb_close
        li      $t3, '['
        li      $t2, ']'
        beq     $t1, $t2, cb_close
        li      $t3, '{'
        li      $t2, '}'
        beq     $t1, $t2, cb_close
        j       cb_loop                 # ky tu khac: bo qua

cb_push:
        addi    $sp, $sp, -4
        sw      $t1, 0($sp)
        j       cb_loop

cb_close:
        beq     $sp, $t9, cb_err_empty  # ngan xep rong
        lw      $t2, 0($sp)             # pop
        addi    $sp, $sp, 4
        bne     $t2, $t3, cb_err_mismatch
        j       cb_loop

cb_err_mismatch:
        move    $v0, $t0
        li      $v1, 1
        j       cb_ret
cb_err_empty:
        move    $v0, $t0
        li      $v1, 2
        j       cb_ret
cb_end:
        beq     $sp, $t9, cb_ok
        addi    $v0, $t0, 1             # do dai + 1
        li      $v1, 3
        j       cb_ret
cb_ok:
        li      $v0, 0
        li      $v1, 0
cb_ret:
        move    $sp, $t9                # can bang $sp tren moi duong thoat
        jr      $ra
