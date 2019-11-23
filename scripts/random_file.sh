#!/bin/bash

function next() {
    path="$*";
    # echo $path
    files=( $path/* )
    echo "${files[RANDOM % ${#files[@]}]}"
}

next $1
