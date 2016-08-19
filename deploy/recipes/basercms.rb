#
# Cookbook Name:: deploy
# Recipe:: basercms-deploy
# Appplication basercms
#

node[:deploy].each do |application, deploy|

  if !node[:app][deploy[:application]].nil? && !node[:app][deploy[:application]].empty?
    custom = node[:app][deploy[:application]]
    
    Chef::Log.info("********** The First deploy::basercms **********")
    # CMS
    include_recipe 'deploy::cms'
    
    # Sync
    include_recipe 'deploy::sync'
    
    Chef::Log.info("********** The Second deploy::basercms **********")
  end
end
