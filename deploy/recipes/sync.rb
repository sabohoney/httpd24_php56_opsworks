#
# Cookbook Name:: deploy
# Recipe:: sync
#

node[:deploy].each do |application, deploy|

  if deploy[:application_type] != 'php' && node[:opsworks][:instance][:layers].first == 'CMS'
    Chef::Log.debug("Skipping deploy::php application #{application} as it is not an PHP app")
    next
  end

    Chef::Log.debug("********* sync *********")
    Chef::Log.debug(node[:app])
    Chef::Log.debug(deploy)
    Chef::Log.debug(node[:opsworsk])

end
