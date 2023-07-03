#!/bin/bash

while true; do
    read -p "Saisissez un chiffre (0 pour quitter) : " chiffre

    if [ "$chiffre" -eq 0 ]; then
        echo "Fin."
        break
    fi

    echo "Multiplication pour le numero $chiffre :"
    for ((i = 1; i <= 10; i++)); do
        result=$(($chiffre * $i))
        echo "$chiffre x $i = $result"
    done

    echo ""
done
