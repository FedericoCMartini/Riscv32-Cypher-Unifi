#!/bin/bash

result=$(grep $1 $2)

if [[ $? -eq 0 ]]; then
    grep -n $1 $2
else
    echo -e "Macro non trovata";
fi