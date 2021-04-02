#!/bin/bash

contract="../clarity-bitcoin.clar"
initial_allocations="./initial-balances.json"
contract_addr="SPP5ERW9P30ZQ9S7KGEBH042E7EJHWDT2Z5K086D"
contract_id="$contract_addr.clarity-bitcoin"
tx_sender="S1G2081040G2081040G2081040G208105NK8PE5"

specific_test="$1"

set -ueo pipefail

which clarity-cli >/dev/null 2>&1 || ( echo >&2 "No clarity-cli in PATH"; exit 1 )

run_test() {
   local test_name="$1"
   local test_dir="$2"
   echo "Run test $test_name"

   local result="$(clarity-cli execute "$test_dir" "$contract_id" "$test_name" "$tx_sender" 2>&1)"
   local rc=$?
   printf "$result\n"
   if [ $rc -ne 0 ] || [ -n "$(echo "$result" | egrep '^Aborted: ')" ]; then
      echo "Test $test_name failed"
      exit 1
   fi
}

for contract_test in $(ls ./test-*.clar); do
   if [ -n "$specific_test" ] && [ "$contract_test" != "$specific_test" ]; then
      continue;
   fi

   test_dir="/tmp/vm-clarity-bitcoin-$(basename "$contract_test").db"
   test -d "$test_dir" && rm -rf "$test_dir"

   mkdir -p "$test_dir"

   clarity-cli initialize "$initial_allocations" "$test_dir"

   echo "Tests begin at line $(wc -l "$contract" | cut -d ' ' -f 1)"
   cat "$contract" "$contract_test" > "$test_dir/contract-with-tests.clar"

   echo "Instantiate $contract_id"
   clarity-cli launch "$contract_id" "$test_dir/contract-with-tests.clar" "$test_dir"

   echo "Run tests"
   tests="$(clarity-cli execute "$test_dir" "$contract_id" "list-tests" "$tx_sender" 2>&1 | \
      grep 'Transaction executed and committed. Returned: ' | \
      sed -r -e 's/Transaction executed and committed. Returned: \((.+)\)/\1/g' -e 's/"//g')"

   echo "$tests"
   set -- $tests

   testname=""
   for i in $(seq 1 $#); do
      eval "test_name=$(echo "\$""$i")"
      run_test "$test_name" "$test_dir"
   done
done
