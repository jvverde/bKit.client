Describe "Sample specfile"
  Describe "hello()"
    hello() {
      echo "hello $1"
    }

    It "puts greeting and no is implemented"
      When call hello world
      The output should eq "hello world"
    End
  End
End
