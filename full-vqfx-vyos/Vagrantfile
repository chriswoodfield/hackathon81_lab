# -*- mode: ruby -*-
# vi: set ft=ruby :

# On Windows, only supported if running under Linux Subsystem for Windows
if Vagrant::Util::Platform.windows?
    puts 'Linux Subsystem for Windows required on Windows hosts.  Please refer to Windows.md for further instruction.'
    abort 
end

VAGRANTFILE_API_VERSION = "2"

UUID = "OGVIFL"
VQFX_PFE_BOX = "juniper/vqfx10k-pfe"
VQFX_RE_BOX = "juniper/vqfx10k-re"
VYOS_BOX = "kun432/vyos"
VYOS_VERSION = "1.3-rolling-202010130117"
CENTOS8_BOX = "centos/7"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.usable_port_range = 12200..12299
    config.ssh.insert_key = false

    (1..2).each do |id|
        re_name  = ( "vqfx" + id.to_s ).to_sym
        pfe_name = ( "vqfx" + id.to_s + "-pfe" ).to_sym
	vyos_name = ( "vyos" + id.to_s ).to_sym
        centos_name = ( "centos" + id.to_s ).to_sym

        ##############################
        ## Packet Forwarding Engine ##
        ##############################
        config.vm.define pfe_name do |vqfxpfe|
            vqfxpfe.ssh.insert_key = false
            vqfxpfe.vm.box = VQFX_PFE_BOX

            # DO NOT REMOVE / NO VMtools installed
            vqfxpfe.vm.synced_folder '.', '/vagrant', disabled: true
            vqfxpfe.vm.network 'private_network', auto_config: false, nic_type: '82540EM', virtualbox__intnet: "#{UUID}_vqfx_internal_#{id}"

            # In case you have limited resources, you can limit the CPU used per vqfx-pfe VM, usually 50% is good
            # vqfxpfe.vm.provider "virtualbox" do |v|
            #    v.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
            # end
        end

        ##########################
        ## Routing Engine  #######
        ##########################
        config.vm.define re_name do |vqfx|
            vqfx.vm.hostname = "vqfx#{id}"
            vqfx.vm.box = VQFX_RE_BOX

            # VM can be really slow unless COM1 is connected to something.
            (File.exist?("/proc/version") and File.readlines("/proc/version").grep(/(Microsoft|WSL)/).size > 0) ? ( re_log = "NUL" ) : ( re_log = "/dev/null" )
            vqfx.vm.provider "virtualbox" do |v|
                v.customize ["modifyvm", :id, "--uartmode1", "file", re_log]
            end

            # DO NOT REMOVE / NO VMtools installed
            vqfx.vm.synced_folder '.', '/vagrant', disabled: true

            # Management port
            vqfx.vm.network 'private_network', auto_config: false, nic_type: '82540EM', virtualbox__intnet: "#{UUID}_vqfx_internal_#{id}"
            vqfx.vm.network 'private_network', auto_config: false, nic_type: '82540EM', virtualbox__intnet: "#{UUID}_reserved-bridge"

            # Dataplane ports
            (1..6).each do |seg_id|
               vqfx.vm.network 'private_network', auto_config: false, nic_type: '82540EM', virtualbox__intnet: "#{UUID}_seg#{seg_id}"
            end
        end

        ##########################
        ## VyOS            #######
        ##########################
        config.vm.define vyos_name do |vyos|
            vyos.vm.box = VYOS_BOX
            vyos.vm.box_version = VYOS_VERSION
            # Dataplane ports
            (1..6).each do |seg_id|
                vyos.vm.network 'private_network', auto_config: false, nic_type: '82540EM', virtualbox__intnet: "#{UUID}_seg#{seg_id}"
            end
        end

        #########################
        ## CentOS Hosts #########
        #########################
        config.vm.define "centos1" do |centos1|
            centos1.vm.hostname = "centos1"
            centos1.vm.box = CENTOS8_BOX
            centos1.vm.network "private_network", type: "dhcp", virtualbox__intnet: "#{UUID}_seg6"
            centos1.vm.provision "shell", inline: <<-SHELL
                yum install -y tcpdump traceroute
                # Manually install static routes. Installing/configuring FRR is a bit over the top for this lab.
                ip route add 10.100.0.0/16 via 10.100.0.1 dev eth1
                ip route add 192.168.0.0/16 via 10.100.0.1 dev eth1
                # Needed for v6 autoconf
                nmcli device modify eth1 ipv6.method auto
                # Vagrant provisions both eth1 and eth2 for no good reason, we only need one
                ip link set dev eth2 down
            SHELL
	end

        config.vm.define "centos2" do |centos2|
            centos2.vm.hostname = "centos2"
            centos2.vm.box = CENTOS8_BOX
            centos2.vm.network "private_network", type: "dhcp", virtualbox__intnet: "#{UUID}_seg5"
            centos2.vm.provision "shell", inline: <<-SHELL
                yum install -y tcpdump traceroute
                # Manually install static routes. Installing/configuring FRR is a bit over the top for this lab.
                ip route add 10.100.0.0/16 via 10.100.1.1 dev eth1
                ip route add 192.168.0.0/16 via 10.100.1.1 dev eth1
                # Needed for v6 autoconf
                nmcli device modify eth1 ipv6.method auto
                # Vagrant provisions both eth1 and eth2 for no good reason, we only need one
                ip link set dev eth2 down
            SHELL
        end
    end


    ##############################
    ## Box provisioning        ###
    ##############################
    config.vm.provision "ansible" do |vqfx|
        vqfx.compatibility_mode = "2.0"
        vqfx.config_file = "ansible.cfg"
        
        vqfx.groups = {
            "vqfx10k" => ["vqfx1", "vqfx2" ],
            "vqfx10kpfe"  => ["vqfx1-pfe", "vqfx2-pfe"],
            "all:children" => ["vqfx10k", "vqfx10kpfe"]
        }
        vqfx.playbook = "pb.conf.all.commit.yaml"
    end

    config.vm.provision "ansible" do |vyos|
        vyos.compatibility_mode = "2.0"
        vyos.config_file = "ansible.cfg"
        vyos.groups = {
            "vyos" => ["vyos1", "vyos2" ],
            "all:children" => ["vyos"]
        }
        vyos.playbook = "pb.vyos.conf.all.yaml"
    end
end

