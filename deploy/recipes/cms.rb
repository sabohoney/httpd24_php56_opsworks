#
# Cookbook Name:: deploy
# Recipe:: cms
# Appplication basercms
#

recipe_name = 'deploy::cms'

node[:deploy].each do |application, deploy|

  if deploy[:application_type] != 'php' || !node[:opsworks][:instance][:layers].include?('cms')
    Chef::Log.debug("Skipping deploy::cms application #{application} as it is not an PHP app")
    next
  end

  if !node[:app][deploy[:application]].nil? && !node[:app][deploy[:application]].empty? && node[:app][deploy[:application]][:run_recipe].include?(recipe_name)
    custom = node[:app][deploy[:application]]
    
    Chef::Log.info("********** The First deploy::basercms-deploy **********")
    # Setting
    configDir = "#{deploy[:deploy_to]}/current/app/Config"
    template "#{configDir}/database.php" do
      group deploy[:group]
      owner deploy[:user]
      mode   '0644'
      variables({
        :APP_NAME => deploy[:application]
      })
      only_if do
        !custom[:db_conf].nil? && custom[:db_conf] == 'create' && File.exists?(configDir)
      end
    end
    
    template "#{configDir}/install.php" do
      group deploy[:group]
      owner deploy[:user]
      mode   '0644'
      variables({
        :deploy => deploy,
        :custom => custom
      })
      only_if do
        !custom[:install].nil? && custom[:install] == "create" && File.exists?(configDir)
      end
    end
    Chef::Log.info("********** The Second deploy::basercms-deploy **********")
  end
end
