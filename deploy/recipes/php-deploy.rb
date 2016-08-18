#
# Cookbook Name:: deploy
# Recipe:: php-deploy
#

include_recipe 'deploy::default'
include_recipe 'deploy::apache-vhost'

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'php'
    Chef::Log.debug("Skipping deploy::php application #{application} as it is not an PHP app")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  deploy[:enable_submodules] = true
  opsworks_deploy do
    deploy_data deploy
    app application
  end

  mode = !node[:mode].nil? && !node[:mode].empty? ? node[:mode] : "production"
  node[:app][application][mode][:run_recipe].each do |recipe|
    include_recipe recipe
    Chef::Log.debug("Execute recipe is #{recipe}")
  end

end
