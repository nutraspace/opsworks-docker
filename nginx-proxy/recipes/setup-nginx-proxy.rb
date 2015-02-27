Chef::Log.info("Setting up the nginx reverse proxy")

node[:deploy].each do |application, deploy|

    if node[:opsworks][:instance][:layers].first != deploy[:environment_variables][:layer]
        Chef::Log.warn("Skipping the deployment of this nginx because it does not match the app layer")
        next
    end

    bash "nginx-proxy-run" do
        user "root"
        code <<-EOH
            docker run -d -p 80:80 -p 443:443 --volumes-from #{deploy[:application]} -v /var/run/docker.sock:/tmp/docker.sock jwilder/nginx-proxy
        EOH
    end
end
