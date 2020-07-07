Describe 'variables.sh'
  Include lib/functions/variables.sh
  It 'set BKITUSER and OS'
    When call _bkit_export_variables
    The status should be success
    The variable BKITUSER should be present
    The variable OS should be present
  End
End
