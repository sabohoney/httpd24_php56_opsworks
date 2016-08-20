#
# Cookbook Name:: deploy
# Recipe:: sync
#

node[:deploy].each do |application, deploy|

  if deploy[:application_type] != 'php'
    Chef::Log.debug("Skipping deploy::php application #{application} as it is not an PHP app")
    next
  end

  if !node[:app][deploy[:application]].nil? && !node[:app][deploy[:application]].empty?
  end
end
