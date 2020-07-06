
#!./test/libs/bats/bin/bats
#https://medium.com/@pimterry/testing-your-shell-scripts-with-bats-abfca9bdc5b9

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

@test "Should add numbers together" {
    assert_equal $(echo 1+1 | bc) 2
}