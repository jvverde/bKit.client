Describe 'dir2dev defined'
  Include lib/dir2dev.sh
  It 'set dir2dev'
    The value dir2dev should be defined
  End
End
Describe 'dir2dev.sh'
  Include lib/dir2dev.sh
  It 'call dir2dev .'
    When call dir2dev .
    The status should be success
    The output should match pattern "/**"
  End
  It 'call dir2dev'
    When call dir2dev
    The status should be success
    The output should match pattern "/**"
  End
  It 'call dir2dev not existing dir'
    When call dir2dev "./___xpto__"
    The status should be success
    The output should match pattern "/**"
  End
  It 'run source dir2dev'
    When run source lib/dir2dev.sh
    The status should be success
    The variable BKITDEV should be present
  End
End