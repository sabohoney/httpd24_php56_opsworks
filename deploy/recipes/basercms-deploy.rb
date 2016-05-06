#
# Cookbook Name:: deploy
# Recipe:: basercms-deploy
#

node[:deploy].each do |app_name, deploy|

  # Setting
  if defined?(node[:basercms_deploy][:db_conf])
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

  if defined?(node[:basercms_deploy][:install])
    template "#{deploy[:deploy_to]}/current/app/Config/install.php" do
      group deploy[:group]
      owner deploy[:user]
      mode   '0644'
      variables({
        :ENV => node[:basercms_deploy][:install]
      })
    end
  end

  if !::File.exists?("#{deploy[:deploy_to]}/current/app/Config/install.php")
    execute "BaserCMS install" do
      command <<-EOH
        cd #{deploy[:deploy_to]} && bin/cake bc_manager install
      EOH
    end
  end

end
