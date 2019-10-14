default['apt']['compile_time_update'] = true
default['build-essential']['compile_time'] = true

default['gocd']['version']='16.1.0-2855'
default['gocd']['agent']['count']=1
default['gocd']['agent']['go_server_host']='127.0.0.1'
default['gocd']['agent']['autoregister']['key']='60e1d87f169feec8eb337502b2f6993aa62cf0b4'
default['gocd']['server_api_ip'] = 'gocd.dev.hara.js-devops.co.uk'
default['gocd']['plugins_dir'] = '/var/lib/go-server/plugins/external'
default['gocd']['plugins_url'] = {
  'deb-repo-poller-1.2.jar'       => 'https://github.com/gocd-contrib/deb-repo-poller/releases/download/1.2/deb-repo-poller-1.2.jar',
  'github-oauth-login-1.2.jar'    => 'https://github.com/gocd-contrib/gocd-oauth-login/releases/download/v1.2/github-oauth-login-1.2.jar',
  'gocd-s3-poller-1.0.0.jar'      => 'https://github.com/schibsted/gocd-s3-poller/releases/download/1.0.0/gocd-s3-poller-1.0.0.jar',
  'github-pr-status-1.1.jar'      => 'https://github.com/gocd-contrib/gocd-build-status-notifier/releases/download/1.1/github-pr-status-1.1.jar',
  'github-pr-poller-1.2.3.jar'    => 'https://github.com/ashwanthkumar/gocd-build-github-pull-requests/releases/download/v1.2.3/github-pr-poller-1.2.3.jar',
  'script-executor-0.2.jar'       => 'https://github.com/gocd-contrib/script-executor-task/releases/download/0.2/script-executor-0.2.jar',
  's3publish-assembly-1.0.29.jar' => 'https://github.com/ind9/gocd-s3-artifacts/releases/download/v1.0.29/s3publish-assembly-1.0.29.jar',
  's3fetch-assembly-1.0.29.jar'   => 'https://github.com/ind9/gocd-s3-artifacts/releases/download/v1.0.29/s3fetch-assembly-1.0.29.jar',
  's3material-assembly-1.0.29.jar' => 'https://github.com/ind9/gocd-s3-artifacts/releases/download/v1.0.29/s3material-assembly-1.0.29.jar',
  'gocd-slack-notifier-1.1.2.jar' => 'https://github.com/ashwanthkumar/gocd-slack-build-notifier/releases/download/v1.1.2/gocd-slack-notifier-1.1.2.jar'
}
default['gocd']['gouser'] = 'devops'
default['gocd']['gituser'] = 'hara-deployer'
default['gocd']['pipeline'] = 'hara-pipeline-configs.git'
default['deploy']['users'] = [
  "root",
  "hara-deployer",
  "go"
]

default['nodejs']['version'] = '4.4.0'
default['nodejs']['install_method'] = 'source'
default['nodejs']['source']['checksum'] = '2cfc76292576d17a8f2434329221675972c96e5fd60cd694610f53134079f92e'
