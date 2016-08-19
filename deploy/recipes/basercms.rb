#
# Cookbook Name:: deploy
# Recipe:: basercms-deploy
# Appplication basercms
#

app_name = 'basercms'
deploy = node[:deploy][app_name]
if !node[:app][app_name].nil? && !node[:app][app_name].empty?
  custom = node[:app][app_name]
  
  Chef::Log.info("********** The First deploy::basercms **********")
  # CMS
  include_recipe 'deploy::cms'
  
  # Sync
  include_recipe 'deploy::sync'
  
  Chef::Log.info("********** The Second deploy::basercms **********")
end
