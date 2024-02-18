#!/bin/bash

if [[ -z $1 ]]; then
  echo "Usage: $0 <file name>"
  echo "Showing balances of wallets in file"
  exit 0
fi

file="$1"
for var in $(cat $file)
do
echo $var - $(solana balance $var)
done
