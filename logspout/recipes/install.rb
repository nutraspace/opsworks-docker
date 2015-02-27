Chef::Log.info("Setting up papertrail")

Chef::Log.info

hostname = "#{node[:opsworks][:stack][:name]}-#{node[:opsworks][:instance][:hostname]}"

Chef::Log.info('docker-logspout start')
bash "docker-logspout" do
    user "root"
    code <<-EOH
        docker run -d -h #{hostname} --name logspout -v /var/run/docker.sock:/tmp/docker.sock progrium/logspout syslog://logs2.papertrailapp.com:44126
    EOH
end
Chef::Log.info('docker-logspout stop')
