#!/bin/bash

if [[ $3 == "continous" ]]; then

    while (true) 
    do
        echo $(exec ~/.config/awesome/scripts/random_file.sh $1)
        sleep $2s;
    done
else
    echo $(exec ~/.config/awesome/scripts/random_file.sh $1)
fi
