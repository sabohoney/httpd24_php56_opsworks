#
# Cookbook Name:: deploy
# Recipe:: phpmyadmin
# Application phpmyadmin
#

node[:deploy].each do |application, deploy|

  if deploy[:application_type] != 'php' && !node[:opsworks][:instance][:layers].include?('cms')
    Chef::Log.debug("Skipping deploy::phpmyadmin application #{application} as it is not an phpmyadmin app")
    next
  end

  if !node[:app][deploy[:application]].nil? && !node[:app][deploy[:application]].empty? && deploy[:application] == node[:app][deploy[:application]][:name]
    custom = node[:app][deploy[:application]]
    
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
  end
end
