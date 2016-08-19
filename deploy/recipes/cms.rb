#
# Cookbook Name:: deploy
# Recipe:: basercms-deploy
# Appplication basercms
#

node[:deploy].each do |application, deploy|

  if !node[:app][deploy[:application]].nil? && !node[:app][deploy[:application]].empty?
    custom = node[:app][deploy[:application]]
    
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
        !custom[:db_conf].nil? && custom[:db_conf] == 'create'
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
        !custom[:install].nil? && custom[:install] == "create"
      end
    end
    Chef::Log.info("********** The Second deploy::basercms-deploy **********")
  end
end
