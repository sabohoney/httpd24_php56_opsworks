#
# Cookbook Name:: deploy
# Recipe:: basercms-deploy
# Appplication basercms
#

app_name = 'basercms'
deploy = node[:deploy][app_name]
mode = !node[:mode].nil? && !node[:mode].empty? ? node[:mode] : "production"
Chef::Log.info("********** deploy::basercms **********")
Chef::Log.info(deploy)
Chef::Log.info(mode)
Chef::Log.info(node[:app])
if node[:app][app_name][mode].nil? || node[:app][app_name][mode].empty?
  custom = node[:app][app_name][mode]
  
  Chef::Log.info("********** The First deploy::basercms **********")
  # CMS
  include_recipe 'deploy::cms'
  
  # Plugin
  include_recipe 'deploy::basercms-plugin'
  
  # Sync
  include_recipe 'deploy::sync'
  
  Chef::Log.info("********** The Second deploy::basercms **********")
end
