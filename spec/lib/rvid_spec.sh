unset BKIT_RVID _export_rvid
Describe 'rvid.sh'
  Include lib/rvid.sh
  It 'defined _export_rvid'
    The value _export_rvid should be defined
  End
  It 'call _export_rvid'
    When call _export_rvid
    The status should be success
    The variable BKIT_R                                                                                                                                   VID should match pattern "[a-zA-Z_].*.*.*" 
  End
End
