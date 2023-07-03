function create_lv() {
    local size_lv
    local user=$1

    # Récupérer la taille maximale à partir de la deuxième ligne de la commande vgs
    local max_size=$(vgs | awk '{print $7}' | sed -n '2p')

    read -p "Quelle taille souhaitez-vous ? " size_lv
    if [ "$size_lv" -gt "$max_size" ]; then
        echo "La taille $size_lv n'est pas disponible (la taille maximale est $max_size Go)"
    else
        echo "Nous allons créer votre espace"
        lvcreate -n lv_"$user" -L "${size_lv}G" vg_cloud
        echo "Le lv a bien été créé"
        file_system "$user"
        montage "$user"
    fi
}



function quel_nom(){
    # Demande le nom de l'utilisateur
    read -p "Quel est votre nom : " nom
}

function file_system(){
    local user=$1
        mkfs.ext4 "/dev/vg_cloud/lv_$user"
}

function montage(){
    local user=$1

    mkdir "/srv/$user"
    echo "/dev/vg_cloud/lv_$user     /srv/$user           ext4 nofail   0       0" >> /etc/fstab
    mount -t ext4 "/dev/vg_cloud/lv_$user" "/srv/$user"
}

# Demande de l'option
read -p "Entrez une option : " option

# L'option est --create
if [ "$option" == "create" ]; then 
    echo "Vous avez choisi l'option création de lv"
    # Demande le nom de l'utilisateur
    quel_nom
    # Test de l'existence de l'utilisateur
    if grep -q "$nom" /etc/passwd ; then
        create_lv "$nom"
        file_system "$nom"
        montage "$nom"
    else
        # Création de l'utilisateur s'il n'existe pas
        echo "Nous allons vous créer un compte utilisateur"
        adduser "$nom"
        create_lv "$nom"
    fi

# L'option est --extend
elif [ "$option" == "extend" ]; then 
    echo "Vous avez choisi l'option extend"
    quel_nom
    read -p "Quelle taille souhaitez-vous ? " size_extend
    lvextend -L "+${size_extend}G" "/dev/vg_cloud/lv_$nom"
    resize2fs "/dev/vg_cloud/lv_$nom"

# L'option est --drop
elif [ "$option" == "drop" ]; then 
    echo "Vous avez choisi la suppression"
    quel_nom
    read -p "Quel est le nom du volume que vous souhaitez supprimer : " nom_vol
    lvremove "/dev/vg_cloud/$nom_vol"
    echo "Le lv $nom_vol de $nom a été supprimé"

# L'option est --reduce
elif [ "$option" == "reduce" ]; then 
    quel_nom
    read -p "Quelle taille souhaitez-vous ? " size_reduce
    umount "/srv/$nom"
    e2fsck -f "/dev/vg_cloud/lv_$nom"
    resize2fs "/dev/vg_cloud/lv_$nom" "${size_reduce}G"
    lvreduce -L "${size_reduce}G" "/dev/vg_cloud/lv_$nom"

else
    echo "
    Options :
                create : Création LV
                extend : Étendre LV
                drop   : Supprimer LV
                reduce : Réduire LV
    "    
fi
