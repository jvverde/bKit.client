Describe 'variables.sh'
  Include lib/functions/variables.sh
  It 'set BKITUSER and OS'
    When call _bkit_export_variables
    The status should be success
    The variable BKITUSER should be present
    The variable OS should be present
  End
End
Describe 'traps.sh'
  Include lib/functions/traps.sh
  It 'defines atexit'
    The value atexit should be a valid funcname
  End
  It 'Runs set traps'
    When call _bkit_set_traps
    The status should be success
  End
End
Describe 'time.sh'
  Include lib/functions/time.sh
  Parameters
    "#1" "@100" "@0" "1m40s"
    "#2" "@60" "@0" "1m0s"
    "#3" "@3601" "@0" "1h0m1s"
    "#4" "@$((3600 * 24))" "@0" "1d0h0m0s"
    "#5" "@$((3600 * 24 * 7))" "@0" "1w0d0h0m0s"
    "#5" "@$((3600 * 24 * 8 + 3659))" "@0" "1w1d1h0m59s"
  End
  It "compute DELTATIME $1"
    When call deltatime "$2" "$3"
    The status should be success
    The variable DELTATIME should equal "$4"
  End
End
Describe 'messages.sh'
  Include lib/functions/messages.sh
  It 'defines msg,warn and die'
    #https://github.com/shellspec/shellspec/blob/master/docs/references.md#valid-matchers
    #"Plan to deprecate in the future."
    #The value msg should be a valid funcname
    #The value warn should be a valid funcname
    #The value die should be a valid funcname
    #The value say should be a valid funcname
    #The value define_say should be a valid funcname
    The value msg should be defined
    The value warn should be defined
    The value die should be defined
    The value say should be defined
    The value define_say should be defined
  End
  It 'runs define_say'     
    When call define_say
    The status should be success
  End
  say(){ :; }
  It 'runs msg (with stub)'
    When call msg
    The status should be success
  End
  It 'runs warn (with stub)'
    When call warn 
    The status should be success
    The variable ERROR should equal 1
  End
  It 'runs die (with stub)'
    When run die
    The status should be failure
  End
End
Describe 'messages(2).sh'
  Include lib/functions/messages.sh
  BeforeAll define_say
  It 'runs say'
    When call say aqui
    The error should equal "aqui"  
    The output should not match pattern "*aqui*" #Trick because tput sedn control characters to output  
  End
  It 'runs msg'
    When call msg aqui
    The line 1 of error should match pattern "*aqui*"  
    The line 2 of error should match pattern "*Called from*"  
  End
End