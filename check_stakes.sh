#!/bin/bash

if [[ -z $1 ]]; then
  echo "Usage: $0 <file name>"
  echo "Showing number of stakes for wallets in file"
  echo "Make DB of current stakes 'solana stakes > stakes.txt'"
  exit 0
fi

file="$1"
for var in $(cat $file)
do
echo $var -  $(cat stakes.txt | grep $var | wc -l)
done
