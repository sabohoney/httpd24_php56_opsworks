#
# Cookbook Name:: deploy
# Recipe:: basercms-deploy
# Appplication basercms
#

app_name = 'basercms'
deploy = node[:deploy][app_name]
if !node[:app][app_name].nil? && !node[:app][app_name].empty?
  custom = node[:app][app_name]
  
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
