#!/bin/bash

export PATH="$HOME/.local/bin:$PATH"

# Obtenir le répertoire parent
parent_dir=$(dirname $(pwd))

# Obtenir la date actuelle
date_str=$(date +"%d-%m-%Y")

# Chemin complet du nouveau dossier
new_folder_path="$parent_dir/$date_str"

# Créer le nouveau dossier s'il n'existe pas déjà
if [ ! -d "$new_folder_path" ]; then
    mkdir "$new_folder_path"
fi

wOutput="$new_folder_path/warmUpOutput"
lOutput="$new_folder_path/LoadOutput"

if [ ! -d "$wOutput" ]; then
    mkdir -p "$wOutput"
fi

if [ ! -d "$lOutput" ]; then
    mkdir -p "$lOutput"
fi

#sleep 60
# Liste des fichiers de charge
# shellcheck disable=SC2054
#workload_files=(
#   "intensity_profile-three-21-06-2024-10min-100.0requests.csv",
#)

workload_dir="../Load/intensity_profiles_2024-07-14"

workload_files=($(ls "$workload_dir"/*.csv))

warmup="intensity_profile-three-26-06-2024-3min-10.0requests.csv"

warmupFile="../warmUp/${warmup}"

echo $warmupFile

export KUBECONFIG=/home/ykoagnenzali/admin.conf

#for file_name in workload_files:
for file_name in "${workload_files[@]}"; do

echo $file_name

input_string=$file_name
output_part=$(basename "$input_string" .csv)
output_part="${output_part#intensity_profile_}"
echo "$output_part"

echo "##################### Initialisation ##################################################"

# Créer le déploiement Kubernetes
kubectl create -f ../custom_deployments/teastore-clusterip-1cpu-5giga.yaml

sleep 300

echo "##################### Sleeping before warmup ##################################################"

#Lancer le générateur de charge HTTP
java -jar httploadgenerator.jar director -s localhost -a "$warmupFile" -l "./teastore_buy.lua" -o "warmup-$output_part.csv" -t 256

echo "##################### Sleeping before load ##################################################"

sleep 240

result="output-$output_part.csv"

res="output-$output_part.csv"


java -jar httploadgenerator.jar director -s localhost -a "$file_name" -l "./teastore_buy.lua" -o $result -t 256

echo "#########################Load Injection finished######################################"

sleep 180

python3 ../Fetcher/PostFetcher.py $res

sleep 180

mv ../Load/intensity_profiles_2024-07-14/$result $lOutput

kubectl delete pods,deployments,services -l app=teastore

sleep 600

done