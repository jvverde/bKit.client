unset BKITDEV _dir2dev 
Describe 'dir2dev.sh'
  Include lib/dir2dev.sh
  It 'set _dir2dev'
    The value _dir2dev should be defined
  End
  It 'call _dir2dev .'
    When call _dir2dev .
    The status should be success
    The output should match pattern "/**"
  End
  It 'call _dir2dev'
    When call _dir2dev
    The status should be success
    The output should match pattern "/**"
  End
  It 'call _dir2dev over a not existing dir'
    When call _dir2dev "./___xpto__"
    The status should be success
    The output should match pattern "/**"
  End
End
Describe '_dir2dev.sh (2)'
  It 'run source _dir2dev'
    When run source lib/dir2dev.sh
    The status should be success
    The value BKITDEV should be present
  End
End