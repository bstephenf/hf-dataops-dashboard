Vagrant::Config.run do |config|
  config.vm.box       = 'precise32'
  config.vm.box_url   = 'http://files.vagrantup.com/precise32.box'
  config.vm.host_name = 'hf-dashboard-dev-box'
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  config.vm.forward_port 3030, 3030

  config.vm.provision :puppet,
    :manifests_path => 'puppet/manifests'
end