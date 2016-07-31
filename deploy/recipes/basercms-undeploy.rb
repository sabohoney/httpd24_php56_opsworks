#
# Cookbook Name:: deploy
# Recipe:: basercms-deploy
#

node[:deploy].each do |app_name, deploy|

  if !deploy[:environment_variables][:type].nil? && deploy[:environment_variables][:type] == "basercms"
    Chef::Log.info("********** The First deploy::basercms-undeploy **********")
    lsyncd_target 'from_s3' do
      action :delete
      notifies :stop, 'service[lsyncd]'
    end
    lsyncd_target 'to_s3' do
      action :delete
      notifies :stop, 'service[lsyncd]'
    end
    Chef::Log.info("********** The Second deploy::basercms-deploy **********")
  end

end
