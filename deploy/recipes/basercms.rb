#
# Cookbook Name:: deploy
# Recipe:: basercms-deploy
# Appplication basercms
#

app_name = 'basercms'
deploy = node[:deploy][app_name]

if node[:basercms][node[:mode]].nil? || node[:basercms][node[:mode]].empty?
  next
end
custom = node[:basercms][node[:mode]]

Chef::Log.info("********** The First deploy::basercms **********")
# CMS
include_recipe 'deploy::cms'

# Plugin
include_recipe 'deploy::basercms-plugin'

# Sync
include_recipe 'deploy::sync'

Chef::Log.info("********** The Second deploy::basercms **********")
