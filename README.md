Full Lab Topology:

![Full Lab Topology](/images/hackathon81_lab_4_devices.png?raw=true "vQFX Full Lab Topology")

Lite Lab Topology:

![Lite Lab Topology](/images/h81_lite_lab_2vqfx_vyos_centos.png?raw=true "vQFX Lite Lab Topology")

## Instructions for Centos 8 lab install ##

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
sudo pip3 install netaddr junos-eznc jxmlease

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
