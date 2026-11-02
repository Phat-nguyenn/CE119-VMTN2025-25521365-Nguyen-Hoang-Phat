###############################################################################
# CE119 - Lab 02 - TN2 - Thong ke diem: stats + histogram (bo T1, T2, T3)
# Sinh vien: Nguyen Hoang Phat - MSSV 25521365 - Lop VMTN2025
# d = 5, k = 8, S = {0,8,2,3,7,10,1,7,0,3,9,8} - MARS 4.5
###############################################################################
        .data
scores:     .word 0, 8, 2, 3, 7, 10, 1, 7, 0, 3, 9, 8   # T1: mang ca nhan, n = 12
t2:         .word 10                                    # T2: n = 1
t3:         .word 4, 4, 4, 4, 4                         # T3: n = 5
grade_tab:  .byte 0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3       # nhom cua diem s = 0..10
            .align 2
hist:       .word 0, 0, 0, 0
tests:      .word scores, 12, t2, 1, t3, 5              # (dia chi mang, n)
ntests:     .word 3
s_test:     .asciiz "== T"
s_eqnl:     .asciiz " ==\n"
s_min:      .asciiz "min="
s_max:      .asciiz " max="
s_g0:       .asciiz "g0="
s_g1:       .asciiz " g1="
s_g2:       .asciiz " g2="
s_g3:       .asciiz " g3="

        .text
        .globl main
# main: $s0 = con tro bang tests, $s1 = so bo con lai, $s2 = so thu tu bo test
main:
        la      $s0, tests
        lw      $s1, ntests
        li      $s2, 1
m_loop:
        beq     $s1, $zero, m_exit
        la      $a0, s_test
        li      $v0, 4
        syscall
        move    $a0, $s2
        li      $v0, 1
        syscall
        la      $a0, s_eqnl
        li      $v0, 4
        syscall
        la      $t0, hist               # xoa hist ve 0
        sw      $zero, 0($t0)
        sw      $zero, 4($t0)
        sw      $zero, 8($t0)
        sw      $zero, 12($t0)

        lw      $a0, 0($s0)             # stats(addr, n)
        lw      $a1, 4($s0)
        jal     stats
        move    $t0, $v0                # giu min/max truoc khi syscall dung $v0
        move    $t1, $v1
        la      $a0, s_min
        li      $v0, 4
        syscall
        move    $a0, $t0
        li      $v0, 1
        syscall
        la      $a0, s_max
        li      $v0, 4
        syscall
        move    $a0, $t1
        li      $v0, 1
        syscall
        li      $a0, 10
        li      $v0, 11
        syscall

        lw      $a0, 0($s0)             # histogram(addr, n, grade_tab, hist)
        lw      $a1, 4($s0)
        la      $a2, grade_tab
        la      $a3, hist
        jal     histogram

        la      $t2, hist
        la      $a0, s_g0
        li      $v0, 4
        syscall
        lw      $a0, 0($t2)
        li      $v0, 1
        syscall
        la      $a0, s_g1
        li      $v0, 4
        syscall
        lw      $a0, 4($t2)
        li      $v0, 1
        syscall
        la      $a0, s_g2
        li      $v0, 4
        syscall
        lw      $a0, 8($t2)
        li      $v0, 1
        syscall
        la      $a0, s_g3
        li      $v0, 4
        syscall
        lw      $a0, 12($t2)
        li      $v0, 1
        syscall
        li      $a0, 10
        li      $v0, 11
        syscall

        addi    $s0, $s0, 8
        addi    $s1, $s1, -1
        addi    $s2, $s2, 1
        j       m_loop
m_exit:
        li      $v0, 10
        syscall

###############################################################################
# stats: tim gia tri nho nhat va lon nhat cua mang word (so co dau)
#   Tham so : $a0 = dia chi mang word, $a1 = n (n >= 1)
#   Tra ve  : $v0 = min, $v1 = max
#   Thanh ghi su dung: $a0, $a1 (bi thay doi), $t0, $t1, $v0, $v1
#   Mot luot duyet, khong ghi bo nho, thu tuc la.
###############################################################################
stats:
        lw      $v0, 0($a0)             # min = max = a[0]
        move    $v1, $v0
st_loop:
        addi    $a1, $a1, -1            # con bao nhieu phan tu chua xet
        beq     $a1, $zero, st_done
        addi    $a0, $a0, 4             # sang phan tu ke tiep
        lw      $t0, 0($a0)
        slt     $t1, $t0, $v0           # x < min ?
        beq     $t1, $zero, st_chkmax
        move    $v0, $t0
st_chkmax:
        slt     $t1, $v1, $t0           # max < x ?
        beq     $t1, $zero, st_loop
        move    $v1, $t0
        j       st_loop
st_done:
        jr      $ra

###############################################################################
# histogram: voi moi diem s, hist[grade_tab[s]] += 1 (tra bang bang lbu)
#   Tham so : $a0 = dia chi mang diem (word), $a1 = n,
#             $a2 = dia chi grade_tab (byte), $a3 = dia chi hist (word)
#   Tra ve  : khong
#   Thanh ghi su dung: $a0, $a1 (bi thay doi), $t0, $t1, $t2
#   Thu tuc la; khong so sanh diem voi nguong.
###############################################################################
histogram:
hg_loop:
        beq     $a1, $zero, hg_done
        lw      $t0, 0($a0)             # s = diem
        add     $t1, $a2, $t0           # &grade_tab[s] (phan tu 1 byte: offset = s)
        lbu     $t1, 0($t1)             # g = grade_tab[s]
        sll     $t1, $t1, 2             # offset byte cua hist[g] = 4*g
        add     $t1, $a3, $t1           # &hist[g]
        lw      $t2, 0($t1)
        addi    $t2, $t2, 1
        sw      $t2, 0($t1)             # hist[g]++
        addi    $a0, $a0, 4
        addi    $a1, $a1, -1
        j       hg_loop
hg_done:
        jr      $ra
