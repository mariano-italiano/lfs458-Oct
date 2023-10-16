# Ładoanie wymaganych modułów
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Konfiguracja systemu
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

# Instalacja containerd
sudo apt-get update && sudo apt-get install -y containerd

sudo mkdir -p /etc/containerd

sudo containerd config default | sudo tee /etc/containerd/config.toml

sed -e 's/SystemdCgroup = false/SystemdCgroup = true/g' -i /etc/containerd/config.toml

sudo systemctl restart containerd

# Wyłączenie swapa
sudo swapoff -a

# Instalacje pakietów pomocniczych/zależnych
apt install curl apt-transport-https vim git wget software-properties-common lsb-release ca-certificates -y

# Dodanie repozytorium K8s do apt
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update

# Instalacja pakietów K8s
sudo apt-get install -y kubeadm=1.27.1-00 kubelet=1.27.1-00 kubectl=1.27.1-00

sudo apt-mark hold kubelet kubeadm kubectl

kubeadm join 192.168.190.40:6443 --token 5lsa9o.63ekhyzcdhnnodvp --discovery-token-ca-cert-hash sha256:cd379ecebc6b98bf1ca3565be3c2e1ed5bccc17e4ab7778324f037cadac699fe
