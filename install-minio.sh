#!/usr/bin/env bash

# update system dependencies
sudo apt update

# download minio binary
echo -e "\e[0;33mDownloading minio binary ...\e[0m\n"
sudo apt install axel -y

axel -a -n 20 https://dl.min.io/server/minio/release/linux-amd64/minio

# make minio executable
echo -e "Making minio executable ...\n"
sudo chmod +x minio

# move minio to bin folder
echo -e "Moving minio to /usr/local/bin folder ...\n"
sudo mv minio /usr/local/bin

# add user group to run minio
echo -e "Create user to run minio as non-root ...\n"
sudo useradd -r minio-user -s /sbin/nologin

# change minio binary ownership
echo -e "Changing minio binary ownership ...\n\n"
sudo chown minio-user:minio-user /usr/local/bin/minio

# create a directory where minio will persist data/buckets
echo -e "Minio default directory for data persistence is ~/.minio-storage-buckets\n"

minioDir=~/Minio_Buckets
mkdir -p $minioDir
sudo chown minio-user -R $minioDir && sudo chmod u+rxw $minioDir

# create directory for minio config files
echo -e "Creating directory for minio config files in /etc/minio ...\n"
sudo mkdir -p /etc/minio

# change ownership of minio config files directory
sudo chown minio-user:minio-user /etc/minio

printf "Enter minio access key. This can be anything:"; read access_key;

printf "\nEnter minio secret key. This can be a random string:"; read secret_key;

echo -e "\nModifying defaults to use keys you entered.\n"

echo -e "MINIO_ACCESS_KEY=\"$access_key\"\nMINIO_VOLUMES=\"$minioDir\"\nMINIO_OPTS=\"--address :9000\"\nMINIO_SECRET_KEY=\"$secret_key\"\n" | sudo tee /etc/default/minio > /dev/null 2>&1 &

echo -e "Downloading minio systemd startup script ... \n"
sudo rm -rf /etc/systemd/system/minio.service
sudo systemctl daemon-reload

curl -O https://raw.githubusercontent.com/minio/minio-service/master/linux-systemd/minio.service

sudo mv minio.service /etc/systemd/system/ && sudo systemctl daemon-reload

sudo killall minio && sudo systemctl enable minio

sudo systemctl start minio

\sleep 2

echo -e "\e[1;34mUse: \n1. Access key \e[1;32m$access_key \n\e[1;34m2. Secret key \e[1;32m$secret_key \e[1;34mand \n3. Port \e[1;32m9000 \e[1;34mto connect to minio server.\n\n";

echo -e "Next steps:\n1. Open port 9000,80, and 443 on your firewall to allow outbound connections to minio server.\n2. Reload firewall to activate changes.\n3. Access admin interface on http://ip-address:9000 e.g. http://127.0.0.1:9000\n\n"

