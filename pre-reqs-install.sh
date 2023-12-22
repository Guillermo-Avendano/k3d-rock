#!/bin/bash

install_docker_compose() {
    echo "Installing docker_compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

install_k3d() {
    echo "Installing k3d..."
    curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
}

install_kubectl() {
    echo "Installing kubectl..."
    curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.22.17/2023-01-30/bin/linux/amd64/kubectl
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/kubectl
}

install_helm() {
    echo "Installing helm..."
    export DESIRED_VERSION=v3.8.2
    curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    sudo sudo apt-get install jq
}

install_terraform() {
    echo "Installing terraform..."
    sudo apt install -y gnupg software-properties-common curl
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt update && sudo apt install terraform
}

is_wsl() {
  case "$(uname -r)" in
  *microsoft* ) true ;; # WSL 2
  *Microsoft* ) true ;; # WSL 1
  * ) false;;
  esac
}

install_docker(){

  if is_wsl; then
    #Update Ubuntu distro
    sudo apt-get -y update
    sudo apt-get -y upgrade
    #Install docker
    sudo apt-get -y install containerd docker.io
    #Call visudo
    printf "\n# Docker daemon specification\n%s ALL=(ALL) NOPASSWD: /usr/bin/dockerd\n" $USER | sudo EDITOR='tee -a' visudo
    #Modify bash settings
    printf "\n# Start Docker daemon automatically when logging in if not running.\nRUNNING=\`ps aux | grep dockerd | grep -v grep\`\nif [ -z \"\$RUNNING\" ]; then\n    sudo dockerd > /dev/null 2>&1 &\n    disown\nfi\n" >> ~/.bashrc
    #Add user to docker group
    sudo usermod -aG docker $USER
    echo -e "\nIn 10 seconds this WSL session will be closed. Then reopen a new WSL session to continue..."
    sleep 10; kill -9 $PPID
  else
    curl -fsSL https://get.docker.com | bash
    #Enable docker service
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
    #Add user to docker group
    sudo usermod -aG docker $USER
    sudo chmod 777 /var/run/docker.sock
    sudo systemctl restart docker.service
  fi
}

install_dos2unix(){
  sudo apt-get -y update
  sudo apt-get -y upgrade
  #install dos2unix
  sudo apt-get install dos2unix

  find . -name "*.yaml" -exec dos2unix {} \;
  find . -name "*.sh" -exec dos2unix {} \;
}

install_helm_repositories(){
  helm repo add runix https://helm.runix.net
  helm repo add portainer https://portainer.github.io/k8s/
  helm repo add bitnami https://charts.bitnami.com/bitnami
  helm repo add elastic https://helm.elastic.co
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

  helm repo add kiali https://kiali.org/helm-charts
  helm repo update
}

install_istio(){
  curl -L https://istio.io/downloadIstio | sh -

  # $HOME/.profile
  #export PATH="$PATH:/home/rocket/istio-1.20.1/bin"

  istioctl x precheck
  istioctl install --set profile=demo -y
  
  helm repo add kiali https://kiali.org/helm-charts
  helm repo update

  helm install \
    --set cr.create=true \
    --set cr.namespace=istio-system \
    --set server.web_fqdn=kiali.local.net \
    --namespace kiali-operator \
    --create-namespace \
    kiali-operator \
    kiali/kiali-operator
    
helm install \
    --namespace istio-system \
    --set server.web_fqdn=example.com \
    kiali-server \
    kiali/kiali-server

  
  sudo yum install jq

}

install_dos2unix

install_docker;

install_docker_compose;

install_kubectl;

install_helm;

install_k3d;

install_helm_repositories

sudo systemctl restart docker.service

sudo chmod 666 //var/run/docker.sock

