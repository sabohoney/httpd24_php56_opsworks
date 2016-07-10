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
  end

end
