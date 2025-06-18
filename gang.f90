program gang_generator
    implicit none
    character(len=256) :: bruh
    character(len=1024) :: output
    integer :: i, len_input, pos
    
    write(*,'(A)', advance='no') 'CAPITAL LETTERS TO CONVERT: '
    read(*,'(A)') bruh
    
    len_input = len_trim(bruh)
    output = ''
    pos = 1
    
    do i = 1, len_input
        output(pos:pos) = bruh(i:i)
        pos = pos + 1
        output(pos:pos+2) = 'ang'
        pos = pos + 3
    end do
    
    write(*,'(A)') output(1:pos-1)
end program gang_generator