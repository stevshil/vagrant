Vagrant.configure(2) do | config |
  # Fedora image
  config.vm.define :fedora do | fedora |
    config.vm.provider "virtualbox" do | vb |
      vb.memory = 2048
      vb.name = "Fedora"
      vb.gui = true
    end
    fedora.vm.host_name = "Fedora"
    fedora.vm.provision :shell, :path => 'bin/fedora.sh'
    fedora.vm.box = "Fedora-Cloud-Base-Vagrant-24-1.2.x86_64.vagrant-virtualbox.box"
    fedora.vm.box_url = "https://download.fedoraproject.org/pub/fedora/linux/releases/24/CloudImages/x86_64/images/Fedora-Cloud-Base-Vagrant-24-1.2.x86_64.vagrant-virtualbox.box"
  end

  # Basic Linux CentOS 7 64 bit
  config.vm.define :basic do | basic |
    config.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      #vb.cpus = 1
      vb.name = "Linux"
      vb.gui = true
    end
    basic.vm.host_name = "Linux"
    basic.vm.provision :shell, :path => 'bin/basic.sh'
  end

  # Basic Linux CentOS 7 64 bit
  config.vm.define :linux do | linux |
    config.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      #vb.cpus = 1
      vb.name = "Linux"
    end
    linux.vm.host_name = "Linux"
  end

  # Python on Linux with GUI
  config.vm.define :python do | python |
    config.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.name = "Python"
      vb.gui = true
    end
    python.vm.host_name = "python"
    python.vm.provision :shell, :path => 'bin/python.sh'
  end

  # Jira basic install
  config.vm.define :jira do | jira |
    config.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      #vb.cpus = 1
      vb.name = "Jira"
    end
    jira.vm.host_name = "jira"
    #jira.vm.box     = "CentOS7.0_x86_64_minimal.box"
    jira.vm.provision :shell, :path => 'bin/jira.sh'
    jira.vm.network "forwarded_port", guest: 8080, host: 1080, protocol: 'tcp'
  end

  # Jenkins basic install, configured with project security
  # admin/admin = user and password
  config.vm.define :jenkins do | jenkins |
    config.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      #vb.cpus = 1
      vb.name = "JenkinsV"
    end
    #jenkins.vm.box     = "CentOS7.0_x86_64_minimal.box"
    #jenkins.vm.network "private_network", ip: "10.0.10.5", virtualbox__intnet: "NatNetwork"
    jenkins.vm.network "public_network", bridge: 'em1', ip: "10.0.10.25"
    jenkins.vm.host_name = "jenkins"
    #jenkins.vm.provision "shell", inline: "/usr/bin/gunzip -c /vagrant/bin/jenkins.sh.gz | /usr/bin/bash -"
    jenkins.vm.provision "shell", inline: "/usr/bin/gunzip -c /vagrant/bin/jenkins.sh.gz >/root/jenkins.sh; /usr/bin/sudo /usr/bin/chmod +x /root/jenkins.sh"
    jenkins.vm.provision "shell", inline: "/usr/bin/sudo /root/jenkins.sh"
    #jenkins.vm.provision :shell, :path => 'bin/jenkins.sh'
    jenkins.vm.network "forwarded_port", guest: 8080, host: 2080, protocol: 'tcp'
  end

  config.vm.define :jjb do | jjb |
    config.vm.provider "virtualbox" do | vb |
      vb.memory = 1024
      vb.name = "Jenkins JBoss"
    end
    jjb.vm.host_name = "jenkins"
    jjb.vm.provision :shell, :path => 'bin/jjb.sh'
    jjb.vm.network "forwarded_port", guest: 8080, host: 58080, protocol: 'tcp'
  end

  # Geneos ITRS training server
  # NOTE: To reprovision ITRS software without reinstall set environment variable
  # e.g.   export ITRS=yes
  config.vm.define :itrs do | itrs |
    config.vm.provider "virtualbox" do | vb |
      vb.memory = 1024
      vb.name = "ITRS"
    end
    #itrs.vm.box = "CentOS7.0_x86_64_minimal.box"
    itrs.vm.host_name = "itrs"
    itrs.vm.provision "shell", :path => 'bin/itrs.sh', :args => "#{ENV['ITRS']}"
    itrs.vm.network "private_network", ip: "192.168.1.200", virtualbox__intnet: true
    itrs.vm.network "forwarded_port", guest: 55801, host: 55801, protocol: 'tcp'
    itrs.vm.network "forwarded_port", guest: 55803, host: 55803, protocol: 'tcp'
    itrs.vm.network "forwarded_port", guest: 55804, host: 55804, protocol: 'tcp'
    itrs.vm.network "forwarded_port", guest: 7041, host: 7041, protocol: 'tcp'
  end

  # ITRS with Docker and trade-app all in one
  config.vm.define :itrsta do | itrsta |
    config.vm.provider "virtualbox" do | vb |
      vb.memory = 2048
      vb.name = "ITRS"
    end
    itrsta.vm.host_name = "itrs"
    itrsta.vm.provision "shell", :path => 'bin/itrs-tradeapp.sh', :args => "#{ENV['ITRS']}"
    itrsta.vm.network "private_network", ip: "192.168.1.200", virtualbox__intnet: true
    itrsta.vm.network "forwarded_port", guest: 55801, host: 55801, protocol: 'tcp'
    itrsta.vm.network "forwarded_port", guest: 55803, host: 55803, protocol: 'tcp'
    itrsta.vm.network "forwarded_port", guest: 55804, host: 55804, protocol: 'tcp'
    itrsta.vm.network "forwarded_port", guest: 7041, host: 7041, protocol: 'tcp'
    itrsta.vm.network "forwarded_port", guest: 3306, host: 3306, protocol: 'tcp'
    itrsta.vm.network "forwarded_port", guest: 8080, host: 8080, protocol: 'tcp'
    itrsta.vm.network "forwarded_port", guest: 9990, host: 9990, protocol: 'tcp'
    itrsta.vm.network "forwarded_port", guest: 8161, host: 8161, protocol: 'tcp'
    itrsta.vm.network "forwarded_port", guest: 61613, host: 61613, protocol: 'tcp'
    itrsta.vm.network "forwarded_port", guest: 61616, host: 61616, protocol: 'tcp'
  end

  # GitLab install using Puppet
  # User and password root/5iveL!fe
  # https://forge.puppetlabs.com/spuder/gitlab
  config.vm.define :gitlab do | gitlab |
    config.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.name = "GitLabV"
    end
    #gitlab.vm.box     = "CentOS7.0_x86_64_minimal.box"
    gitlab.vm.network "private_network", ip: "10.0.10.20", virtualbox__intnet: "NatNetwork"
    gitlab.vm.host_name = "gitlab"
    gitlab.vm.provision "shell", :path => 'bin/gitlab.sh'
    gitlab.vm.provision "puppet" do | puppet |
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "gitlab.pp"
      puppet.module_path = "puppet/modules"
      puppet.hiera_config_path = "puppet/hiera.yaml"
      #puppet.working_directory = "/vagrant/puppet/hiera"
      puppet.options = "--verbose --debug"
    end
    gitlab.vm.network "forwarded_port", guest: 80, host: 1280, protocol: 'tcp'
    gitlab.vm.network "forwarded_port", guest: 22, host: 1122, protocol: 'tcp'
  end

  # FreeIPA LDAP server
  config.vm.define :freeipa do | freeipa |
    config.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.name = "LDAP"
    end
    freeipa.vm.network "public_network", bridge: 'wlp3s0b1', type: "dhcp"
    freeipa.vm.network "private_network", ip: "10.0.10.15", virtualbox__intnet: "NatNetwork"
    #freeipa.vm.box = "CentOS7.0_x86_64_minimal.box"
    freeipa.vm.host_name = "ldap.training.local"
    freeipa.vm.provision "shell", :path => 'bin/freeipa.sh'
    freeipa.vm.provision "puppet" do | puppet |
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "freeipa.pp"
      puppet.module_path = "puppet/modules"
      puppet.hiera_config_path = "puppet/hiera.yaml"
      puppet.options = "--verbose --debug"
    end
  end

  # Linux network installation server
  config.vm.define :installer do | installer |
    config.vm.provider "virtualbox" do |vb|
      vb.memory = 512
      vb.name = "PXE"
    end
    installer.vm.network "private_network", ip: "192.168.1.254", virtualbox__intnet: true
    #installer.vm.box = "CentOS7.0_x86_64_minimal.box"
    installer.vm.host_name = "installer.training.local"
    installer.vm.provision "shell", :path => 'bin/generic.sh'
    installer.vm.provision "puppet" do | puppet |
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "installer.pp"
      puppet.module_path = "puppet/modules"
      puppet.hiera_config_path = "puppet/hiera.yaml"
      puppet.options = "--verbose"
    end
  end

  # Linux router to bridge a physical network through Laptop NAT
  config.vm.define :router do | router |
    config.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.name = "ROUTER"
    end
    router.vm.network "public_network", bridge: 'em1', ip: "192.168.1.254"
    #router.vm.box = "CentOS7.0_x86_64_minimal.box"
    router.vm.host_name = "router.training.local"
    router.vm.provision "shell", :path => 'bin/router.sh'
  end

  # Open Puppet
  config.vm.define :openpuppet do | openpuppet |
    config.vm.provider "virtualbox" do | vb |
      vb.memory = 4096
      vb.name = "OpenPuppet"
    end
    openpuppet.vm.network "private_network", ip: "192.168.18.100"
    openpuppet.vm.host_name = "puppetmaster.training.local"
    openpuppet.vm.provision "shell", :path => "bin/openpuppet.sh"
  end

  config.vm.define :openpuppetclient do | openpuppetclient |
    config.vm.provider "virtualbox" do | vb |
      vb.memory = 512
      vb.name = "OpenPuppetClient"
    end
    openpuppetclient.vm.network "private_network", ip: "192.168.18.101"
    openpuppetclient.vm.host_name = "puppetclient.training.local"
    openpuppetclient.vm.provision "shell", :path => "bin/openpuppet.sh"
  end

  config.vm.define :studentpuppet do | studentpuppet |
    config.vm.provider "virtualbox" do | vb |
      vb.memory = 512
      vb.name = "studentpuppet"
    end
    studentpuppet.vm.network "private_network", ip: "192.168.18.102"
    studentpuppet.vm.host_name = "student.training.local"
    studentpuppet.vm.provision "shell", :path => "bin/openpuppet.sh"
  end

  # Jenkins for openpuppet
  # admin/admin = user and password
  config.vm.define :jenkinspuppet do | jenkinspuppet |
    config.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      #vb.cpus = 1
      vb.name = "JenkinsPuppet"
    end
    jenkinspuppet.vm.network "private_network", ip: "192.168.18.105"
    jenkinspuppet.vm.host_name = "jenkins"
    jenkinspuppet.vm.provision "shell", inline: "/usr/bin/gunzip -c /vagrant/bin/jenkins.sh.gz >/root/jenkins.sh; /usr/bin/sudo /usr/bin/chmod +x /root/jenkins.sh"
    jenkinspuppet.vm.provision "shell", inline: "/usr/bin/sudo /root/jenkins.sh"
    jenkinspuppet.vm.network "forwarded_port", guest: 8080, host: 2080, protocol: 'tcp'
  end

  # GitLab for openpuppet course
  # User and password root/5iveL!fe
  # https://forge.puppetlabs.com/spuder/gitlab
  # https://docs.gitlab.com/omnibus/maintenance/README.html
  config.vm.define :gitlabpuppet do | gitlabpuppet |
    config.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.name = "GitLabPuppet"
    end
    gitlabpuppet.vm.network "private_network", ip: "192.168.18.110"
    gitlabpuppet.vm.host_name = "gitlab"
    gitlabpuppet.vm.provision "shell", :path => 'bin/gitlab.sh'
    gitlabpuppet.vm.provision "puppet" do | puppet |
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "gitlab.pp"
      puppet.module_path = "puppet/modules"
      puppet.hiera_config_path = "puppet/hiera.yaml"
      #puppet.working_directory = "/vagrant/puppet/hiera"
      puppet.options = "--verbose --debug"
    end
    gitlabpuppet.vm.provision "shell", inline: "/usr/bin/sudo /opt/gitlab/bin/gitlab-ctl reconfigure"
    gitlabpuppet.vm.network "forwarded_port", guest: 80, host: 1280, protocol: 'tcp'
    gitlabpuppet.vm.network "forwarded_port", guest: 22, host: 1122, protocol: 'tcp'
  end

  # Puppet Load Balancer
  config.vm.define :puppetlb do | puppetlb |
    config.vm.provider "virtualbox" do | vb |
      vb.memory = 512
      vb.name = "PuppetLB"
    end
    puppetlb.vm.network "private_network", ip: "192.168.18.100"
    #puppetlb.vm.box = "CentOS7.0_x86_64_minimal.box"
    puppetlb.vm.host_name = "puppetmaster.training.local"
    puppetlb.vm.provision "shell", :path => 'bin/puppetlb.sh'
  end

  # Puppet Standalone CA for scaling example
  config.vm.define :puppetca do | puppetca |
    config.vm.provider "virtualbox" do | vb |
      vb.memory = 1024
      vb.name = "PuppetCA"
    end
    puppetca.vm.network "private_network", ip: "192.168.18.10"
    #puppetca.vm.box = "CentOS7.0_x86_64_minimal.box"
    puppetca.vm.host_name = "puppetca.training.local"
    puppetca.vm.provision "shell", :path => 'bin/puppetca.sh'
  end

  # Puppet Worker to go with Puppet CA
  config.vm.define :puppetworker do | puppetworker |
    config.vm.provider "virtualbox" do | vb |
      vb.memory = 1024
      vb.name = "PuppetWorker"
    end
    puppetworker.vm.network "private_network", ip: "192.168.18.12"
    #puppetworker.vm.box = "CentOS7.0_x86_64_minimal.box"
    puppetworker.vm.host_name = "puppetworker.training.local"
    puppetworker.vm.provision "shell", :path => 'bin/puppetworker.sh'
  end

  # Puppet Worker 2 to go with Puppet CA
  config.vm.define :puppetworker2 do | puppetworker2 |
    config.vm.provider "virtualbox" do | vb |
      vb.memory = 1024
      vb.name = "PuppetWorker2"
    end
    puppetworker2.vm.network "private_network", ip: "192.168.18.11"
    #puppetworker2.vm.box = "CentOS7.0_x86_64_minimal.box"
    puppetworker2.vm.host_name = "puppetsrv.training.local"
    puppetworker2.vm.provision "shell", :path => 'bin/puppetworker.sh'
  end

  # Puppet Passenger server
  config.vm.define :puppetpass do | puppetpass |
    config.vm.provider "virtualbox" do | vb |
      vb.memory = 1024
      vb.name = "PuppetSRV"
    end
    puppetpass.vm.network "private_network", ip: "192.168.18.110"
    #puppetpass.vm.box = "CentOS7.0_x86_64_minimal.box"
    puppetpass.vm.host_name = "puppetsrv.training.local"
    puppetpass.vm.provision "shell", :path => 'bin/puppet-passenger.sh'
  end

  # Puppet File server for shared certs and host info
  config.vm.define :puppetnfs do | puppetnfs |
    config.vm.provider "virtualbox" do | vb |
      vb.memory = 512
      vb.name = "PuppetNFS"
    end
    puppetnfs.vm.network "private_network", ip: "192.168.18.5"
    #puppetnfs.vm.box = "CentOS7.0_x86_64_minimal.box"
    puppetnfs.vm.host_name = "puppetnfs.training.local"
    puppetnfs.vm.provision "shell", :path => 'bin/puppetnfs.sh'
  end

  # Puppet client
  config.vm.define :puppetcli do | puppetcli |
    config.vm.provider "virtualbox" do | vb |
      vb.memory = 512
      vb.name = "PuppetClient"
    end
    puppetcli.vm.network "private_network", ip: "192.168.18.20"
    #puppetcli.vm.box = "CentOS7.0_x86_64_minimal.box"
    puppetcli.vm.host_name = "puppetcli.training.local"
    puppetcli.vm.provision "shell", :path => 'bin/puppet-client.sh'
  end
  # Debian
  config.vm.define :webdeb do |webdeb|
    config.vm.provider "virtualbox" do | vb |
      vb.memory = 1024
      vb.name = "webdeb"
    end
    webdeb.vm.host_name = "webuntu"
    webdeb.vm.box = "debwheezy.box"
    webdeb.vm.box_url = "https://dl.dropboxusercontent.com/u/67225617/lxc-vagrant/lxc-wheezy64-puppet3-2013-07-27.box"
  end

  # Tomcat server
  config.vm.define :tomcat do | tomcat |
	config.vm.provider "virtualbox" do | vb |
      vb.memory = 1024
      vb.name = "tomcat"
    end
	tomcat.vm.host_name = "tomcat"
	tomcat.vm.provision "shell", :path => 'bin/tomcat.sh'
	tomcat.vm.network "forwarded_port", guest: 8080, host: 1180, protocol: 'tcp'
  end

  # JBoss server
  config.vm.define :jboss do | jboss |
	config.vm.provider "virtualbox" do | vb |
      vb.memory = 1024
      vb.name = "jboss"
    end
	jboss.vm.host_name = "jboss"
	jboss.vm.provision "shell", :path => 'bin/jboss.sh'
	jboss.vm.network "forwarded_port", guest: 8080, host: 1280, protocol: 'tcp'
  end

  # Project planning server (Kanban board)
  config.vm.define :kanboard do | kanboard |
	config.vm.provider "virtualbox" do | vb |
      vb.memory = 1024
      vb.name = "kanboard"
    end
	kanboard.vm.host_name = "kanboard"
	kanboard.vm.provision "shell", :path => 'bin/kanboard.sh'
	kanboard.vm.network "forwarded_port", guest: 80, host: 1380, protocol: 'tcp'
  end

    # osTicket a Production Support ticketing system
  config.vm.define :osticket do | osticket |
	config.vm.provider "virtualbox" do | vb |
      vb.memory = 1024
      vb.name = "osticket"
    end
	osticket.vm.host_name = "osticket"
	osticket.vm.provision "shell", :path => 'bin/osTicket.sh'
	osticket.vm.network "forwarded_port", guest: 80, host: 1480, protocol: 'tcp'
  end

    # Logstash server
    config.vm.define :logstash do | logstash |
	config.vm.provider "virtualbox" do | vb |
          vb.memory = 1024
          vb.name = "logstash"
        end
	logstash.vm.host_name = "logstash"
	logstash.vm.provision "shell", :path => 'bin/logstash.sh'
	logstash.vm.network "forwarded_port", guest: 5601, host: 5601, protocol: 'tcp'
    end

    # Docker test VM
    config.vm.define :docker do | docker |
      config.vm.provider "virtualbox" do | vb |
        vb.memory = 2048
        vb.name = "Docker"
      end
      docker.vm.host_name = "docker"
      #docker.vm.synced_folder "/home/steve/dockersite", "/home/vagrant/dockersite"
      docker.vm.provision "shell", :path => 'bin/docker.sh'
      #docker.vm.network "forwarded_port", guest: 80, host: 80, protocol: 'tcp'
      docker.vm.network "forwarded_port", guest: 1080, host: 1080, protocol: 'tcp'
      docker.vm.network "forwarded_port", guest: 1180, host: 1180, protocol: 'tcp'
      docker.vm.network "forwarded_port", guest: 8080, host: 8080, protocol: 'tcp'
      docker.vm.network "forwarded_port", guest: 50000, host: 50000, protocol: 'tcp'
    end

    # My laptop web server
    config.vm.define :lws do | lws |
      config.vm.provider "virtualbox" do | vb |
        vb.memory = 1024
        vb.name = 'laptopwebserver'
      end
      lws.vm.host_name = 'lws'
      lws.vm.provision "shell", :path => 'bin/lws.sh'
      lws.vm.network "forwarded_port", guest: 80, host: 1080, protocol: 'tcp'
      lws.vm.network "forwarded_port", guest: 3306, host: 3316, protocol: 'tcp'
      lws.vm.synced_folder "/home/web-apps", "/home/web-apps"
      lws.vm.synced_folder "/home/mysql", "/copy/mysql"
    end

    # Ansible on CentOS
    config.vm.define :acos do | acos |
      config.vm.provider "virtualbox" do | vb |
        vb.memory = 1024
        vb.name = "ansible-cos"
      end
      acos.vm.host_name = "acos"
      acos.vm.provision "shell", :path => 'bin/ansible.sh'
      acos.vm.network "private_network", ip: "192.168.1.50", virtualbox__intnet: "intnet"
    end

    # Ansible client
    config.vm.define :ansible do | ansible |
      config.vm.provider "virtualbox" do | vb |
        vb.memory = 1024
        vb.name = "ansible-client"
      end
      ansible.vm.host_name = "ansibleclient"
      ansible.vm.network "private_network", ip: "192.168.1.51", virtualbox__intnet: "intnet"
    end

    # Ansible on Ubunutu
    config.vm.define :adeb do | adeb |
      config.vm.provider "virtualbox" do | vb |
        vb.memory = 1024
        vb.name = "ansible-debian"
      end
      adeb.vm.host_name = "adeb"
      adeb.vm.provision "shell", :path => 'bin/ansible.sh'
      adeb.vm.box = "ubuntu/trusty64"
    end

    # Ubuntu 64bit unity with GUI for KODI
    config.vm.define :kodi do | kodi |
      config.vm.provider "virtualbox" do | vb |
        vb.memory = 2048
        vb.name = "KODI"
        #vb.gui = true
      end
      kodi.vm.box = "tranchung/kubuntu-1604-x64"
      kodi.vm.provision "shell", :path => 'bin/kodi.sh'
      kodi.vm.network "public_network", bridge: 'bond0'
    end

    # Keepalived 1
    config.vm.define :ka1 do | ka1 |
      config.vm.provider "virtualbox" do | vb |
        vb.memory = 512
        vb.name = "Keepalive 1"
      end
      ka1.vm.provision "shell", :path => 'bin/keepalive.sh'
      ka1.vm.network "private_network", ip: "10.0.0.200"
    end

    # Keepalived 2
    config.vm.define :ka2 do | ka2 |
      config.vm.provider "virtualbox" do | vb |
        vb.memory = 512
        vb.name = "Keepalive 2"
      end
      ka2.vm.provision "shell", :path => 'bin/keepalive.sh'
      ka2.vm.network "private_network", ip: "10.0.0.210"
    end

    # MySQL Cluster
    config.vm.define :mymgm do | mymgm |
      config.vm.provider "virtualbox" do | vb |
        vb.memory = 1024
        vb.name = "MySQL Manager"
      end
      mymgm.vm.provision "shell", :path => "bin/mysql-cluster.sh"
      mymgm.vm.network "private_network", ip: "10.0.0.2"
    end
    config.vm.define :mynode1 do | mynode1 |
      config.vm.provider "virtualbox" do | vb |
        vb.memory = 1024
        vb.name = "MySQL Node 1"
      end
      mynode1.vm.provision "shell", :path => "bin/mysql-cluster.sh"
      mynode1.vm.network "private_network", ip: "10.0.0.3"
    end
    config.vm.define :mynode2 do | mynode2 |
      config.vm.provider "virtualbox" do | vb |
        vb.memory = 1024
        vb.name = "MySQL Node 2"
      end
      mynode2.vm.provision "shell", :path => "bin/mysql-cluster.sh"
      mynode2.vm.network "private_network", ip: "10.0.0.4"
    end

    # Real RHEL 7 not CentOS
    config.vm.define :realrhel do | rhel |
      config.vm.provider "virtualbox" do | vb |
        vb.memory = 1024
        vb.name = "Real RedHat EL 7"
      end
      rhel.vm.box     = "gwhorley/rhel72-x86_64"
    end

    # Puppet AWS automation client
    config.vm.define :alpuppet do | openpuppetclient |
      config.vm.provider "virtualbox" do | vb |
        vb.memory = 512
        vb.name = "OpenPuppetClient"
      end
      openpuppetclient.vm.network "public_network", bridge: 'bond0'
      openpuppetclient.vm.host_name = "puppetclient.training.local"
      openpuppetclient.vm.provision "shell", :path => "bin/openpuppet.sh"
    end

    # Bitcoin miner
    config.vm.define :bitminer do | btmine |
      config.vm.provider "virtualbox" do | vb |
        vb.memory = 2048
        vb.name = "BitCoin Miner"
      end
      btmine.vm.host_name = "bitmin.localdomain"
      btmine.vm.provision "shell", :path => "bin/bitminer.sh"
      btmine.vm.box = "boxcycler/bywater"
    end

    # TeamCity
    config.vm.define :teamcity do | teamcity |
      config.vm.provider "virtualbox" do | vb |
        vb.memory = 2048
        vb.name = "TeamCity"
      end
      teamcity.vm.host_name = "teamcity.localdomain"
      teamcity.vm.provision "shell", :path => "bin/teamcity.sh"
      teamcity.vm.network "forwarded_port", guest: 8111, host: 8111, protocol: 'tcp'
    end

    # TeamCity Docker
    config.vm.define :tcdocker do | tcdocker |
      config.vm.provider "virtualbox" do | vb |
        vb.memory = 2048
        vb.name = "TeamCity Docker"
      end
      tcdocker.vm.host_name = "tcdocker.localdomain"
      tcdocker.vm.provision "shell", :path => "bin/teamcity-docker.sh"
      tcdocker.vm.network "forwarded_port", guest: 8111, host: 8111, protocol: 'tcp'
    end

    # GitGerrit server
    config.vm.define :gg do | gitgerrit |
      config.vm.provider "virtualbox" do | vb |
        vb.memory = 2048
        vb.name = "GitGerrit"
      end
      gitgerrit.vm.host_name = "gitgerrit.localdomain"
      gitgerrit.vm.provision "shell", :path => "bin/gitgerrit.sh"
      gitgerrit.vm.network "public_network", bridge: 'wlp1s0'
    end

    # Atomic Host
    config.vm.define :atomic do | atomic |
      config.vm.provider "virtualbox" do | vb |
        vb.memory = 3096
        vb.name = "atomic"
      end
      atomic.vm.host_name = "atomic.localdomain"
      atomic.vm.network "public_network", bridge: 'wlp1s0'
      atomic.vm.box = "centos/atomic-host"
    end
  # Defaults
  # Changing to using Hashicorp public boxes
  # https://atlas.hashicorp.com/boxes/search
  config.vm.box = "bento/centos-7.2"
  config.ssh.username = "vagrant"
  #config.ssh.password = "vagrant"
  #config.vm.box     = "CentOS7.0_x86_64_minimal.box"
  #config.vm.box_url = "file://#{ENV['HOME']}/Documents/Vagrant/boxFiles/CentOS7-base.box"
  #config.ssh.private_key_path= "#{ENV['HOME']}/.ssh/vagrant_id"
  # Windows boxes
  #config.vm.box_url = "http://aka.ms/vagrant-win7-ie11"
  # See http://blog.syntaxc4.net/post/2014/09/03/windows-boxes-for-vagrant-courtesy-of-modern-ie.aspx
end
