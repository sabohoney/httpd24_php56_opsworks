#
# Cookbook Name:: deploy
# Recipe:: basercms-deploy
#

node[:deploy].each do |app_name, deploy|

  Chef::Log.info("********** #{app_name}:#{deploy} **********")
  if app_name == "phpmyadmin"
    # Setting
    template "#{deploy[:deploy_to]}/config.inc.php" do
      group deploy[:group]
      owner deploy[:user]
      mode   '0644'
    end
  end

end
