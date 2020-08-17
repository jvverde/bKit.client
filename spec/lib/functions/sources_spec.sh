Describe 'sources.sh'
  Include lib/functions/source.sh
  It 'set _bkit_source'
    The value _bkit_source should be defined
  End
  It 'source variables'
    When call _bkit_source variables
    The status should be success
    The variable BKITUSER should be present
    The variable OS should be present
  End
  It 'source variables, traps and sendnotify'
    When call _bkit_source variables traps notify
    The status should be success
    The variable BKITUSER should be present
    The variable OS should be present
    The value atexit should be defined
    The value sendnotify should be defined
  End
End
