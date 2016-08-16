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

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  node[:application][node[:mode]][:run_recipe].each do |recipe|
    include_recipe recipe
  end

end

