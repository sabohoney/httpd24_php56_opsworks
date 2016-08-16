#
# Cookbook Name:: deploy
# Recipe:: phpmyadmin
# Application phpmyadmin
#

app_name = 'phpmyadmin'
deploy = node[:deploy][app_name]
mode = !node[:mode].nil? && !node[:mode].empty? ? node[:mode] : "develop"
if node[:app][app_name][mode].nil? || node[:app][app_name][mode].empty?
  next
end
custom = node[:app][app_name][mode]

# Install
composer_project "#{deploy[:deploy_to]}/current/" do
  dev false
  quiet true
  action :install
end
# Setting
template "#{deploy[:deploy_to]}/current/config.inc.php" do
  group deploy[:group]
  owner deploy[:user]
  mode   '0644'
end
execute "phpMyAdmin Language Setup" do
  cwd "#{deploy[:deploy_to]}/current"
  command "scripts/generate-mo"
end
directory "#{deploy[:deploy_to]}/current/config" do
  recursive true
  action :delete
end
