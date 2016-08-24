#
# Cookbook Name:: deploy
# Recipe:: nfs
#

include_recipe 'deploy::default'

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'other' || !node[:app][deploy[:application]][:init]
    Chef::Log.debug("Skipping deploy::nfs application #{application} as it is not an NFS app")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  node[:app][deploy[:application]][:run_recipe].each do |recipe|
    include_recipe recipe
  end

end

