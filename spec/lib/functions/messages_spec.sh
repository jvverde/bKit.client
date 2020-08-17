Describe 'messages.sh'
  Include lib/functions/messages.sh
  It 'defines say,warn and die'
    #https://github.com/shellspec/shellspec/blob/master/docs/references.md#valid-matchers
    #"Plan to deprecate in the future."
    #The value msg should be a valid funcname
    #The value warn should be a valid funcname
    #The value die should be a valid funcname
    #The value say should be a valid funcname
    #The value define_say should be a valid funcname
    The value warn should be defined
    The value die should be defined
    The value say should be defined
  End
  It 'call define_say'     
    When call define_say
    The status should be success
  End
  say(){ :; }
  It 'call warn (with stub)'
    When call warn 
    The status should be success
    The variable ERROR should equal 1
    The status should be success
  End
  It 'runs die (with stub)'
    When run die
    The status should be failure
  End
End
Describe 'messages(2).sh'
  Include lib/functions/messages.sh
  BeforeAll define_say
  It 'call say'
    When call say aqui
    The error should equal "aqui"  
    The output should not match pattern "*aqui*" #Trick because tput sedn control characters to output  
    The status should be success
  End
  It 'call msg'
    When call msg aqui
    The line 1 of error should match pattern "*aqui*"  
    The line 2 of error should match pattern "*Called from*"  
    The status should be success
  End
  It 'run die'
    When run die aqui
    The line 1 of error should match pattern "*aqui*"  
    The line 2 of error should match pattern "*Called from*" 
    The status should be failure
  End
End