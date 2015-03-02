Chef::Log.info("Setting up papertrail")

node[:deploy].each do |application, deploy|

    if node[:opsworks][:instance][:layers].first != deploy[:environment_variables][:layer]
        Chef::Log.warn("Skipping the deployment of this papertrail because it does not match the app layer")
        next
    end

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
            docker run -d --restart=always -h #{hostname} --name logspout -v /var/run/docker.sock:/tmp/docker.sock progrium/logspout syslog://#{deploy[:environment_variables][:PAPERTRAIL_URL]}:#{deploy[:environment_variables][:PAPERTRAIL_PORT]}
        EOH
    end
    Chef::Log.info('docker-logspout stop')
end
