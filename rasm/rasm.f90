! RASM - RAKIAC assembler
! translates RASM into RAKIAC machine language
! command line use: rasm input.rasm output.rexe
program rasm
  implicit none

  character(16) :: carg1, carg2
  character(32) :: ins, ml
  character(32) :: op, a1, a2
  integer :: line
  integer*2 :: adr, bnk

  real :: start, end, time

  call getarg(1, carg1)
  call getarg(2, carg2)

  open(8, file = carg1) ! in
  open(9, file = carg2) ! out

  print *, "rasm source: ", carg1
  print *, "rexe output: ", carg2
  print *, ""

  call cpu_time(start)

  line = 0

  do while(ins /= "end")
     read(8, "(A)") ins
     ins = trim(ins)

     call parse(ins, op, a1, a2)

     !print *, op
     !print *, a1
     !print *, a2
     !print *, type

     ml = ops(op, a1, a2)

     bnk = ishft(line, -4)
     adr = line - ishft(bnk, 4)
     write(*, "(I4 ' | ' I2 ', '  I2 ' |  ' A10A)") line, bnk, adr, ml, ins
     write(9, "(A8)") ml

     line = line + 1
  end do

  call cpu_time(end)

  time = end - start

  print *, ""
  print *, "Assembly completed in: ", time, " s"

  close(8)
  close(9)
contains
  subroutine parse(ins, op, a1, a2)
    character(32) :: ins
    character(32) :: op, a1, a2

    logical :: ns, ons
    character :: c
    integer :: i, word

    op = ""
    a1 = ""
    a2 = ""
    i = 1
    word = 0
    ns = .true.

    do while (i <= 32 .and. word < 3)
       c = ins(i:i)

       ons = ns

       ns = c /= " " .and. c /= "," &
            .and. c /= "\r" .and. c /= "\n" &
            .and. c /= "\r\n"

       if (ns .and. .not. ons) then
          word = word + 1
       end if

       if (ns) then
          select case (word)
          case (0)
             op = trim(op) // c
          case (1)
             a1 = trim(a1) // c
          case (2)
             a2 = trim(a2) // c
          end select
       end if

       i = i + 1
    end do
  end subroutine parse

  function ctob4(c) result(b) ! char to bit 4
    character(32) :: c
    character(32) :: b
    integer :: i

    read(c, *) i
    write(b, "(B4.4)") i   
  end function ctob4
  
  function ctob3(c) result(b) ! char to bit 3
    character(32) :: c
    character(32) :: b
    integer :: i

    read(c, *) i
    write(b, "(B3.3)") i   
  end function ctob3

  function ctob2(c) result(b) ! char to bit 2
    character(32) :: c
    character(32) :: b
    integer :: i

    read(c, *) i
    write(b, "(B2.2)") i   
  end function ctob2
  
  function ctob1(c) result(b) ! char to bit 1
    character(32) :: c
    character(32) :: b
    integer :: i

    read(c, *) i
    write(b, "(B1.1)") i   
  end function ctob1
  
  function ctoi(c) result(b) ! char to integer
    character(32) :: c
    integer :: b
    integer :: i

    read(c, *) i
    b = i
  end function ctoi
  
  function itoc(i) result(b) ! integer to char
    character(32) :: c
    character(32) :: b
    integer :: i

    write(c, *) i
    b = c
  end function itoc
  
  function rtob2(r) result(b) ! register name to bit 2
    character(32) :: r
    character(32) :: b

    select case(r)
    case ("a")
       b = "00"
    case ("b")
       b = "01"
    case ("c")
       b = "10"
    case ("d")
       b = "11"
    end select
  end function rtob2

  function ops(op, a1, a2) result(ml)
    character(32) :: op, a1, a2
    character(32) :: ml
    character(32) :: ac1, ac2
    integer :: ai1, ai2

    select case (op)
    case ("nop")
       ml = "00000000"
    case ("hlt")
       ml = "00000001"
    case ("end")
       ml = "00000010"
    case ("atm")
       ml = "00001000"
    case ("mta")
       ml = "00001001"
    case ("atp")
       ml = "00001010"
    case ("pta")
       ml = "00001111"
    case ("lda")
       ml = "00001100"
    case ("sta")
       ml = "00001101"
    case ("sw")
       ml = "0001"
       ml = trim(ml) // trim(ctob4(a1))
    case ("jmp")
       ml = "0010"
       ml = trim(ml) // trim(ctob4(a1))
    case ("jez")
       ml = "0011"
       ml = trim(ml) // trim(ctob4(a1))
    case ("jlz")
       ml = "0100"
       ml = trim(ml) // trim(ctob4(a1))
    case ("mov")
       ml = "0101"
       ml = trim(ml) // trim(rtob2(a1))
       ml = trim(ml) // trim(rtob2(a2))
    case ("sto")
       ml = "0110"
       ml = trim(ml) // trim(ctob4(a1))
    case ("ld")
       ml = "0111"
       ml = trim(ml) // trim(ctob4(a1))
    case ("ldi")
       ml = "1000"
       ml = trim(ml) // trim(ctob4(a1))
    case ("not")
       ml = "1001"
       ml = trim(ml) // trim(rtob2(a1))
       ml = trim(ml) // "00"
    case ("and")
       ml = "1010"
       ml = trim(ml) // trim(rtob2(a1))
       ml = trim(ml) // trim(rtob2(a2))
    case ("or")
       ml = "1011"
       ml = trim(ml) // trim(rtob2(a1))
       ml = trim(ml) // trim(rtob2(a2))
    case ("xor")
       ml = "1100"
       ml = trim(ml) // trim(rtob2(a1))
       ml = trim(ml) // trim(rtob2(a2))
    case ("add")
       ml = "1101"
       ml = trim(ml) // trim(rtob2(a1))
       ml = trim(ml) // trim(rtob2(a2))
    case ("sub")
       ml = "1110"
       ml = trim(ml) // trim(rtob2(a1))
       ml = trim(ml) // trim(rtob2(a2))
    case ("sh")
       ml = "1111"
       ml = trim(ml) // trim(ctob1(a1))
       ml = trim(ml) // trim(ctob3(a2))
    case ("")
       ml = "00000000"
    case default
       ml = op
    end select
  end function ops
end program rasm
