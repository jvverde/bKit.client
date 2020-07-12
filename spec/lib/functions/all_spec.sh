unset _bkit_source_all BKITUSER OS
Describe 'sources.sh'
  Include lib/functions/all.sh
  It 'defind _bkit_source_all'
    The value _bkit_source_all should be defined
  End
  It 'source all'
    When call _bkit_source_all
    The status should be success
    The variable BKITUSER should be present
    The variable OS should be present
    The value atexit should be defined
    The value sendnotify should be defined
    The value mktempdir should be defined
    The value die should be defined
  End
End
