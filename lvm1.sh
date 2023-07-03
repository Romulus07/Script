#!/bin/bash

# Fonction pour tester l'argument 'user'
test_argument(){
    while [ -z "$user" ]
    do
        read -p "Quel est votre nom ?" user
    done
    echo "Bienvenue $user"
}

# Fonction pour poser la question sur la taille et créer le volume logique
question_taille(){
    while [ -z "$size" ]
    do
        read -p "Quelle taille souhaitez-vous ?" size
    done
    max_size=40 
    if [ "$size" -lt "$max_size" ]; then
        lvcreate -n lv_"$user" -L "${size}G" vg_cloud
    else
        echo "Manque d'espace"
    fi
}

# Appel de la fonction pour tester l'argument 'user'
test_argument

# Vérifier si l'utilisateur existe, sinon le créer
if ! id "$user" >/dev/null 2>&1; then
    adduser -m "$user" /home/"$user"
    passwd "$user"
    echo "Bienvenue $user"
    question_taille
    mkdir "/mnt/$user"
    echo "/dev/vg_cloud/lv_$user     /srv/$user           ext4 nofail   0       0" >> /etc/fstab
    mount -t ext4 "/dev/vg_cloud/lv_$user" "/srv/$user"
fi









# Vérifier si l'utilisateur existe dans /etc/passwd
if grep -q "$user" /etc/passwd; then
    read -p "Quel est votre besoin (extension/réduction) ? " reponse
    case $reponse in
        "extension")
            read -p "Quelle taille souhaitez-vous ? " size_extend
            Test_espace
            lvextend -L "+${size_extend}G" "/dev/vg_cloud/lv_$user"
            resize2fs "/dev/vg_cloud/lv_$user"
            ;;
        "réduction")
            echo "Commande réduction."
            read -p "Quelle taille souhaitez-vous ? " size
            test_espace
            umount "/srv/$user"
            e2fsck -f "/dev/vg_cloud/lv_$user"
            resize2fs "/dev/vg_cloud/lv_$user" "${size}G"
            lvreduce -L "${size}G" "/dev/vg_cloud/lv_$user"
            ;;
        *)
            echo "Réponse invalide."
            ;;
    esac
fi
