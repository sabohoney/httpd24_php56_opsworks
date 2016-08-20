#
# Cookbook Name:: deploy
# Recipe:: undeploy
#

node[:deploy].each do |application, deploy|

  Chef::Log.info("********** The First deploy::undeploy **********")
  directory "#{deploy[:deploy_to]}" do
    recursive true
    action :delete
  end
  Chef::Log.info("********** The Second deploy::undeploy **********")

end
