unset BKIT_RVID _export_rvid
Describe 'rvid.sh'
  Include lib/rvid.sh
  It 'defined _export_rvid'
    The value _export_rvid should be defined
  End
  It 'call _export_rvid'
    When call _export_rvid
    The status should be success
    The lines of output should equal 0
    The variable BKIT_RVID should match pattern "[a-zA-Z_].*.*.*" 
  End
End
Describe
  It 'run _export_rvid'
    When run lib/rvid.sh
    The status should be success
    The lines of output should equal 1
    The output should match pattern "[a-zA-Z_].*.*.*" 
  End
  It 'run source _export_rvid'
    When run source lib/rvid.sh
    The status should be success
    The lines of output should equal 0
  End
End
