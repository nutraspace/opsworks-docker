Chef::Log.info("Setting up papertrail")

Chef::Log.info

hostname = "#{node[:opsworks][:stack][:name]}-#{node[:opsworks][:instance][:hostname]}"

bash "docker-logspout-cleanup" do
    user "root"
    code <<-EOH
        if docker ps | grep logspout;
        then
            docker stop logspout
            sleep 3
            docker rm -f logspout
        fi
        if docker ps -a | grep logspout;
        then
            docker rm -f logspout
        fi
        if docker images | grep progrium/logspout;
        then
            docker rmi -f $(docker images | grep -m 1 progrium/logspout | awk {'print $3'})
        fi
    EOH
end

Chef::Log.info('docker-logspout start')
bash "docker-logspout" do
    user "root"
    code <<-EOH
        docker run -d -h #{hostname} --name logspout -v /var/run/docker.sock:/tmp/docker.sock progrium/logspout syslog://logs2.papertrailapp.com:44126
    EOH
end
Chef::Log.info('docker-logspout stop')
