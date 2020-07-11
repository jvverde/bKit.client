unset BKITDRIVE _drives
Describe 'drive.sh'
  Include lib/drive.sh
  It 'defined _drive'
    The value _drives should be defined
  End
  It 'call _drives'
    When call _drives a b c d
    The lines of output should equal 4
    The line 1 of output should match pattern "*|*|*|*" 
    The line 2 of output should match pattern "*|*|*|*" 
    The line 3 of output should match pattern "*|*|*|*" 
    The line 4 of output should match pattern "*|*|*|*" 
  End
End
Describe 'drive.sh (2)'
  It 'run sourced _drive'
    When run source lib/drive.sh
    The status should be success
    The value BKITDRIVE should be present
  End
End
