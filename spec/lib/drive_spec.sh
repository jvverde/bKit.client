unset BKITDRIVE _drives _exportdrive
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
  It 'call _exportdrive'
    When call _exportdrive
    The status should be success
    The variable BKITDRIVE should be present
  End
End
