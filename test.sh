#!/bin/bash


pvcreate /dev/sdb /dev/sdc 
vgcreate "vg_cloud"   /dev/sdb /dev/sdc

test_peripherique() {
    if lsblk | grep -q "/dev/sd[b-d]"; then
        echo "Périphérique de stockage détecté."
    else
        echo "Aucun périphérique de stockage détecté."
        echo "Veuillez ajouter un disque."
    fi
}

vg_size() {
    size=$1
    espace=$(vgs | awk '{print $7}' | sed -n "2p")
    if [ "$size" -lt "$espace" ]; then
        echo "L'espace est suffisant."
    else
        echo "L'espace est insuffisant."
        # Ajoutez ici la commande pour créer le pv (manquante dans le script)
    fi
}



# Nouvel utilisateur

read -p "Quel est votre nom ? " user

if ! id "$user" >/dev/null 2>&1; then
    sudo adduser -m "$user" /home/"$user"
    sudo passwd "$user"
    read -p "Quelle est la taille souhaitée ? " size
    echo "test_espace"
    lvcreate -n lv_"$user" -L "${size}G" vg_cloud
fi

# Extension ou réduction

if grep -q "$user" /etc/passwd; then
    read -p "Quel est votre besoin (extension/réduction) ? " reponse
    case $reponse in
        "extension")
            read -p "Quelle taille souhaitez-vous ? " size_extend
            echo "Test espace"
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


