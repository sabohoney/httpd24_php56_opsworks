#
# Cookbook Name:: deploy
# Recipe:: basercms-deploy
# Appplication basercms
#

app_name = 'basercms'
deploy = node[:deploy][app_name]
mode = !node[:mode].nil? && !node[:mode].empty? ? node[:mode] : "develop"
if node[:app][app_name][mode].nil? || node[:app][app_name][mode].empty?
  next
end
custom = node[:app][app_name][mode]

Chef::Log.info("********** The First deploy::basercms **********")
# CMS
include_recipe 'deploy::cms'

# Plugin
include_recipe 'deploy::basercms-plugin'

# Sync
include_recipe 'deploy::sync'

Chef::Log.info("********** The Second deploy::basercms **********")
