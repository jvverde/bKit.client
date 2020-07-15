unset BKIT_RVID _export_rvid
Describe 'rvid.sh'
  Include lib/rvid.sh
  It 'defined _export_rvid'
    The value _export_rvid should be defined
  End
  It 'call _export_rvid'
    When call _export_rvid
    The status should be success
    The lines of output should equal 1
    The variable BKIT_RVID should match pattern "[a-zA-Z_].*.*.*" 
  End
End
