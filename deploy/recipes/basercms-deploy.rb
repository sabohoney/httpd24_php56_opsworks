#
# Cookbook Name:: deploy
# Recipe:: basercms-deploy
#

node[:deploy].each do |app_name, deploy|

  if !deploy[:environment_variables][:type].nil? && deploy[:environment_variables][:type] == "basercms"
    Chef::Log.info("********** The First deploy::basercms-deploy **********")
    # Setting
    template "#{deploy[:deploy_to]}/current/app/Config/database.php" do
      group deploy[:group]
      owner deploy[:user]
      mode   '0644'
      variables({
        :APP_NAME => app_name
      })
      only_if do
        node[:environment_variables][:db_conf] == 'create'
      end
    end
  
    template "#{deploy[:deploy_to]}/current/app/Config/install.php" do
      group deploy[:group]
      owner deploy[:user]
      mode   '0644'
      variables({
        :deploy => deploy
      })
      only_if do
        !deploy[:environment_variables][:install].nil? && deploy[:environment_variables][:install] == "create"
      end
    end
  
    # s3 Sync
    #include_recipe 'deploy::s3sync'
    # Plugin
    #include_recipe 'deploy::basercms-plugin'
    Chef::Log.info("********** The Second deploy::basercms-deploy **********")
  end

end
