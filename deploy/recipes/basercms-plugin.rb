#
# Cookbook Name:: basercms-plugin
# Recipe:: upload
# Appplication basercms
#
app_name = 'basercms'
deploy = node[:deploy][app_name]
mode = !node[:mode].nil? && !node[:mode].empty? ? node[:mode] : "production"
if !node[:app][app_name][mode].nil? && !node[:app][app_name][mode].empty?
  custom = node[:app][app_name][mode]
  
  Chef::Log.info("********** The First deploy::basercms-plugin **********")
  if !::File.exists?(deploy[:home])
    opsworks_deploy_user do
      deploy_data deploy
    end
  end
  Chef::Log.info("********** The Second deploy::basercms-plugin **********")
  if !custom[:plugin].nil?
    if ::File.exists?("#{deploy[:deploy_to]}/current/app/Plugin")
      directory "#{deploy[:deploy_to]}/current/app/Plugin" do
        action :delete
        recursive true
      end
    end
    git_ssh_wrapper app_name do
      owner deploy[:user]
      group deploy[:group]
      ssh_key_data deploy[:scm][:ssh_key]
    end
    git "#{deploy[:deploy_to]}/current/app/Plugin" do
      repo custom[:plugin]
      revision 'master'
      user deploy[:user]
      group deploy[:group]
      action :checkout
      ssh_wrapper "#{Etc.getpwnam(deploy[:user]).dir}/.ssh/wrappers/#{app_name}_deploy_wrapper.sh"
    end
  end
  Chef::Log.info("********** The Third deploy::basercms-plugin **********")
end
