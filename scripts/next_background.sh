#!/bin/bash

while (true) 
do
    echo $(exec ~/.config/awesome/scripts/random_file.sh $1)
    sleep $2s;
done
