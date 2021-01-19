## Create a VM with VMX enabled in GCP
gcloud compute disks create lab1 --image-project centos-cloud --image-family centos-8 --zone us-central1-b

gcloud compute images create hackathon-lab-1 --source-disk lab1 --source-disk-zone us-central1-b --licenses "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"

gcloud compute instances create hackathon-lab-1 --zone us-central1-b \
              --min-cpu-platform "Intel Haswell" \
              --image hackathon-lab-1

## Edit machine in GUI - min 32GB RAM

# Install latest Vagrant release
sudo dnf -y install https://releases.hashicorp.com/vagrant/2.2.14/vagrant_2.2.14_x86_64.rpm

# Install VirtualBox
# Enable repo
sudo dnf -y install wget
sudo wget https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo
sudo mv virtualbox.repo /etc/yum.repos.d/
sudo wget -q https://www.virtualbox.org/download/oracle_vbox.asc
sudo rpm --import oracle_vbox.asc
sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

# Install required libs/modules
sudo dnf -y install binutils kernel-devel kernel-headers libgomp make patch gcc glibc-headers glibc-devel dkms
sudo dnf install -y VirtualBox-6.1

# Install Ansible and plugins
sudo dnf install -y ansible
ansible-galaxy install Juniper.junos
sudo pip3 install netaddr

# Clone the lab repo
sudo dnf install -y git
mkdir lab
cd lab
git clone https://github.com/chriswoodfield/hackathon81_lab

# And provision it all!
export VAGRANT_DEFAULT_PROVIDER=virtualbox
vagrant up

# If centos1/2 provisioning displays errors about invalid routes, recreate those VMs
vagrant destroy -f centos1 centos2 && vagrant up centos1 centos2
