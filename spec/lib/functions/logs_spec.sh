declare tmpdir=tmpdir
makedir() {
  tmpdir="$(mktemp -d --suffix=".spec")"
}
rmdir() { 
  #Just be very cautious with rm -rf
  [[ -d $tmpdir && $tmpdir =~ ^/tmp/tmp\..+\.spec ]] && rm -rf "$tmpdir" 
}

Describe 'logs.sh'
  Include lib/functions/logs.sh
  BeforeAll "makedir"
  AfterAll "rmdir"
  It 'defines say,warn and die'
    The value redirectlogs should be defined
  End
  It 'call redirectlogs logs'     
    When call redirectlogs "$tmpdir"
    The status should be success
    The line 1 of output should match pattern "Logs go to *"  
    The line 2 of output should match pattern "Errors go to *"
    The error should not equal "aquiiiiiiiiiiiii" 
  End
End