#
## Cookbook Name:: sainsburys-gocd-hara
## Recipe:: default.rb
##
## Copyright (c) 2015 The Authors, All Rights Reserved.
#
## Following dependencies need installing on Ubuntu 1404
#
## Get the users passwords from the databag
gosuer=['dev','admin']
access_key='abc'
secret_key='xyz'

node['gocd_agent']['auto_register']['key'] = '60e1d87f169feec8eb337502b2f6993aa62cf0b4'
#
# Add permissions file
template '/etc/go/gocd.pw' do
source 'gocd.pw.erb'
  owner 'go'
  group 'go'
  mode '600'
  variables ({
    :users => gousers
  })
end

# Install plugins
# Install required plugins in list
node['gocd']['plugins_url'].each_pair do | plname, plurl |
  log "DATA: #{plname} = #{plurl}"
  remote_file "#{node['gocd']['plugins_dir']}/#{plname}" do
    source plurl
    action :create
    notifies :restart, 'service[go-server]'
    not_if "test -f #{node['gocd']['plugins_dir']}/#{plname}"
  end
end

# Get current system time to back up configuration
curTime = Time.new.strftime("%Y%m%d-%H%M")

# Install or update configuration
cookbook_file "/etc/go/cruise-config.xml.orig" do
  source "#{node.chef_environment}-cruise-config.xml"
end

# Back up current configuration if the cruise-config.xml.orig has been updated
if node.chef_environment == 'development'
  execute "backup_config" do
    command "cp /etc/go/cruise-config.xml /etc/go/cruise-config.xml-#{curTime}"
    only_if "test /etc/go/cruise-config.xml.orig -nt /etc/go/cruise-config.xml"
  end
end

# Restart server and agent if the config has changed
execute "change_config" do
  command "cp /etc/go/cruise-config.xml.orig /etc/go/cruise-config.xml"
  only_if "test /etc/go/cruise-config.xml.orig -nt /etc/go/cruise-config.xml"
  notifies :restart, 'service[go-server]', :immediately
end

# Add AWS attributes to /etc/default/go-server to allow S3 poller to work
execute "Update AWS Access to config file #{access_key}" do
  command "sed -i \"s/export AWS_ACCESS_KEY_ID=.*/export AWS_ACCESS_KEY_ID='#{access_key}'/\" /etc/default/go-server"
  only_if 'grep "AWS_ACCESS_KEY_ID" /etc/default/go-server'
end

execute "Add AWS Access to config file #{access_key}" do
  command "echo \"export AWS_ACCESS_KEY_ID='#{access_key}'\" >>/etc/default/go-server"
  not_if 'grep "AWS_ACCESS_KEY_ID" /etc/default/go-server'
end

execute "Update AWS Secret to config file #{secret_key}" do
  command "sed -i \"s/export AWS_SECRET_ACCESS_KEY=.*/export AWS_SECRET_ACCESS_KEY='#{secret_key}'/\" /etc/default/go-server"
  only_if 'grep "AWS_SECRET_ACCESS_KEY" /etc/default/go-server'
end

execute "Add AWS Secret to config file #{secret_key}" do
  command "echo \"export AWS_SECRET_ACCESS_KEY='#{secret_key}'\" >>/etc/default/go-server"
  not_if 'grep "AWS_SECRET_ACCESS_KEY" /etc/default/go-server'
end

service "go-server" do
  action :nothing
end

# Allow go to run chef-client
execute "Add go to sudoers file" do
  command 'echo "go ALL=(ALL) NOPASSWD:/opt/chefdk/bin/chef-client" >>/etc/sudoers'
  not_if 'grep "go ALL=.*" /etc/sudoers'
end

# Stop chef from continually running, should only run when change occurs
service 'chef-client' do
  action [ :disable, :stop ]
end

directory '/var/go/pipelines' do
  owner 'go'
  group 'go'
  mode  '0700'
  action :create
  recursive true
end

# Create environment variables file
template '/etc/go/govars.env' do
  source 'govars.env.erb'
  owner 'go'
  group 'go'
  mode '0600'
  variables ({
    :gouser => node[:go_cd][:gouser],
    :gopass => gopass,
    :goserver => node['go_cd']['server_api_ip'],
    :gituser => node[:go_cd][:gituser],
    :gitpassword => gitpw
  })
end


template '/var/go/pipelines/Seeder.json' do
  source 'pipelines/seed.json.erb'
  owner 'go'
  group 'go'
  mode  '0600'
  variables ({
    :gituser => node[:gocd][:gituser],
    :gitpassword => gitpw,
    :pipeline => node['gocd']['pipeline']
  })
  notifies :run, 'execute[Run seed pipeline]'
  not_if 'grep Seeder /etc/go/cruise-config.xml'
end

# Execute seed jobs
execute 'Run seed pipeline' do
  command '. /etc/go/govars.env && /bin/go-api.sh set /var/go/pipelines/Seeder.json'
  action :nothing
  not_if '. /etc/go/govars.env && /bin/go-api.sh get Seeder | grep "name.*Seeder"'
end
