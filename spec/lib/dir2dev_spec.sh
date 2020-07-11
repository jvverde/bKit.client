Describe 'dir2dev.sh'
  Include lib/dir2dev.sh
  It 'set dir2dev'
    The value dir2dev should be defined
  End
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
  It 'call dir2dev over a not existing dir'
    When call dir2dev "./___xpto__"
    The status should be success
    The output should match pattern "/**"
  End
End
Describe 'dir2dev.sh (2)'
  It 'run source dir2dev'
    When run source lib/dir2dev.sh
    The status should be success
    The variable BKITDEV should be present
  End
End