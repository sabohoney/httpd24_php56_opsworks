#
# Cookbook Name:: deploy
# Recipe:: nfs-deploy
#

include_recipe 'deploy::default'

node[:deploy].each do |application, deploy|
  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

end

