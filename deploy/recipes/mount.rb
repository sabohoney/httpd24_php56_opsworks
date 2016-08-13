#
# Cookbook Name:: deploy
# Recipe:: s3sync
#

node[:deploy].each do |app_name, deploy|

  env = deploy[:environment_variables]
  if !env[:sync].nil? && env[:sync] == "on"
    directory "#{deploy[:deploy_to]}/current/app/webroot" do
      recursive true
      action :delete
    end
    directory "#{deploy[:deploy_to]}/current/app/webroot" do
      user deploy[:user]
      action :create
      recursive true
    end
    # Mount
    Chef::Log.debug(node[:deploy])
    mount "#{deploy[:deploy_to]}/current/app/webroot" do
      device   "#{env[:nfs_host]}:#{node[:deploy][:NFS][:deploy_to]}/webroot"
      fstype   'nfs'
      options  "defaults"
      action   [:mount, :enable]
    end
  end

end
