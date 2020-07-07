Describe 'traps.sh'
  Include lib/functions/traps.sh
  It 'defines atexit'
    The value atexit should be a valid funcname
  End
  It 'call set traps'
    When call _bkit_set_traps
    The status should be success
  End
End
