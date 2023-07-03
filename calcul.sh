#!/bin/bash

arg1=$1
arg2=$2

while true; do
    read -p "Quelle opération souhaitez-vous effectuer? (+, -, x, /, %) : " operation

    if [[ "$operation" =~ ^[+x/%-]$ ]]; then
        break
    else
        echo "Opération non valide. Veuillez réessayer."
    fi
done

if ! [[ "$arg1" =~ ^[0-9]+$ ]]; then
    echo "Erreur : Le premier argument n'est pas un nombre valide."
    exit 1
fi

if ! [[ "$arg2" =~ ^[0-9]+$ ]]; then
    echo "Erreur : Le deuxième argument n'est pas un nombre valide."
    exit 1
fi

num1=$arg1
num2=$arg2

if [ "$operation" == "+" ]; then
    result=$((num1 + num2))
    echo "Résultat : $result"
elif [ "$operation" == "-" ]; then
    result=$((num1 - num2))
    echo "Résultat : $result"
elif [ "$operation" == "x" ]; then
    result=$((num1 * num2))
    echo "Résultat : $result"
elif [ "$operation" == "/" ]; then
    if [ "$num2" -ne 0 ]; then
        result=$((num1 / num2))
        echo "Résultat : $result"
    else
        echo "Erreur : Division par zéro."
    fi
elif [ "$operation" == "%" ]; then
    if [ "$num2" -ne 0 ]; then
        result=$((num1 % num2))
        echo "Résultat : $result"
    else
        echo "Erreur : Division par zéro."
    fi
fi

