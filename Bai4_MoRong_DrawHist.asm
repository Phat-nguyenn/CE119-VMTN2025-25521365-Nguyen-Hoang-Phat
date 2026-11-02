###############################################################################
# CE119 - Lab 02 - Phan mo rong - Truc quan hoa pho diem: draw_hist (bo T1)
# Sinh vien: Nguyen Hoang Phat - MSSV 25521365 - Lop VMTN2025
# d = 5, k = 8, S = {0,8,2,3,7,10,1,7,0,3,9,8} - MARS 4.5
###############################################################################
        .data
scores:     .word 0, 8, 2, 3, 7, 10, 1, 7, 0, 3, 9, 8   # T1: mang ca nhan, n = 12
grade_tab:  .byte 0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3
            .align 2
hist:       .word 0, 0, 0, 0

        .text
        .globl main
main:
        la      $a0, scores             # histogram(scores, 12, grade_tab, hist)
        li      $a1, 12
        la      $a2, grade_tab
        la      $a3, hist
        jal     histogram
        la      $a0, hist               # draw_hist(hist, 4)
        li      $a1, 4
        jal     draw_hist
        li      $v0, 10
        syscall

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

###############################################################################
# draw_hist (phan mo rong): ve pho diem bang ky tu '|'
#   Tham so : $a0 = dia chi mang hist (word), $a1 = so nhom (4)
#   Tra ve  : khong. In moi nhom 1 dong: "g<i>: " + hist[i] ky tu '|'
#   Thanh ghi su dung: $a0, $v0 (syscall), $t0..$t3
#   Thu tuc la (chi dung syscall, khong jal).
###############################################################################
draw_hist:
        move    $t0, $a0                # $t0 = con tro hist ($a0 bi syscall dung)
        li      $t1, 0                  # $t1 = chi so nhom i
dh_loop:
        beq     $t1, $a1, dh_done
        li      $a0, 'g'
        li      $v0, 11
        syscall
        move    $a0, $t1
        li      $v0, 1
        syscall
        li      $a0, ':'
        li      $v0, 11
        syscall
        li      $a0, ' '
        li      $v0, 11
        syscall
        lw      $t2, 0($t0)             # so sinh vien cua nhom i
        li      $a0, '|'
        li      $v0, 11
dh_bar:
        beq     $t2, $zero, dh_eol
        syscall
        addi    $t2, $t2, -1
        j       dh_bar
dh_eol:
        li      $a0, 10
        li      $v0, 11
        syscall
        addi    $t0, $t0, 4
        addi    $t1, $t1, 1
        j       dh_loop
dh_done:
        jr      $ra
