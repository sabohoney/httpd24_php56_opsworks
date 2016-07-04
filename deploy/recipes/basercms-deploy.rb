#
# Cookbook Name:: deploy
# Recipe:: basercms-deploy
#

node[:deploy].each do |app_name, deploy|

  # Setting
  if node[:basercms_deploy][:db_conf] != false
    template "#{deploy[:deploy_to]}/current/app/Config/database.php" do
      group deploy[:group]
      owner deploy[:user]
      mode   '0644'
      variables({
        :CORE => node[:basercms_deploy][:db_conf][:core],
        :PLUGIN => node[:basercms_deploy][:db_conf][:plugin],
        :TEST => node[:basercms_deploy][:db_conf][:test]
      })
    end
  end

  if node[:basercms_deploy][:install] != false
    template "#{deploy[:deploy_to]}/current/app/Config/install.php" do
      group deploy[:group]
      owner deploy[:user]
      mode   '0644'
      variables({
        :ENV => node[:basercms_deploy][:install]
      })
    end
  end

  if !::File.exists?("#{deploy[:deploy_to]}/current/app/Config/install.php") && node[:basercms_deploy][:install] == true
    execute "BaserCMS install" do
      command <<-EOH
        cd #{deploy[:deploy_to]}/current/app && Console/cake bc_manager install
      EOH
    end
  end
  # s3 Sync
  include_recipe 'deploy::s3sync'
  # Plugin
  include_recipe 'deploy::basercms-plugin'

end
