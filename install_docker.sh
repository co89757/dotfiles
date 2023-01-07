# tested for ubuntu 22 
sudo apt update 
echo "---- Install prerequisite packages -----"
# install a few prerequisite packages which let apt use packages over HTTPS:
sudo apt install apt-transport-https ca-certificates curl software-properties-common
# Then add the GPG key for the official Docker repository to your system:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
# Make sure you are about to install from the Docker repo instead of the default Ubuntu repo:
echo "---- Running apt-cache policy docker-ce -----------"
apt-cache policy docker-ce
## expected output
# docker-ce:
#   Installed: (none)
#   Candidate: 5:20.10.14~3-0~ubuntu-jammy
#   Version table:
#      5:20.10.14~3-0~ubuntu-jammy 500
#         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
#      5:20.10.13~3-0~ubuntu-jammy 500
#         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages

echo "------ install docker --------"
sudo apt install docker-ce

echo "------- Run docker without sudo ------"
sudo usermod -aG docker $USER 
echo "------- Active new group memership ----"
su - ${USER} 
echo "------- Confirm group change ---- "
groups 

echo " ------- Install Docker compose ---- "

mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.15.0/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose