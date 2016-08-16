#
# Cookbook Name:: deploy
# Recipe:: basercms-deploy
# Appplication basercms
#

app_name = 'basercms'
deploy = node[:deploy][app_name]
mode = !node[:mode].nil? && !node[:mode].empty? ? node[:mode] : "develop"
if node[:app][app_name][mode].nil? || node[:app][app_name][mode].empty?
  next
end
custom = node[:app][app_name][mode]

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
