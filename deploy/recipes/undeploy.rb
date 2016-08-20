#
# Cookbook Name:: deploy
# Recipe:: basercms-deploy
#

node[:deploy].each do |app_name, deploy|

  if !deploy[:environment_variables][:type].nil? && deploy[:environment_variables][:type] == "basercms"
    Chef::Log.info("********** The First deploy::basercms-undeploy **********")
    Chef::Log.info("********** The Second deploy::basercms-undeploy **********")
  end

end
