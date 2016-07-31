#
# Cookbook Name:: deploy
# Recipe:: basercms-deploy
#

node[:deploy].each do |app_name, deploy|

  if app_name == "phpmyadmin"
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
