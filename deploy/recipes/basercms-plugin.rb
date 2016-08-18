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
  user = File.exists?(deploy[:home]) ? deploy[:user] : 'ec2-user'
  group = File.exists?(deploy[:home]) ? deploy[:group] : 'ec2-user'
  home = File.exists?(deploy[:home]) ? deploy[:home] : Etc.getpwnam('ec2-user').dir
  Chef::Log.info("********** The Second deploy::basercms-plugin **********")
  if !custom[:plugin].nil?
    if ::File.exists?("#{deploy[:deploy_to]}/current/app/Plugin")
      directory "#{deploy[:deploy_to]}/current/app/Plugin" do
        action :delete
        recursive true
      end
    end
    git_ssh_wrapper app_name do
      owner user
      group group
      ssh_key_data deploy[:scm][:ssh_key]
    end
    git "#{deploy[:deploy_to]}/current/app/Plugin" do
      repo custom[:plugin]
      revision 'master'
      user user
      group group
      action :checkout
      ssh_wrapper "#{Etc.getpwnam(user).dir}/.ssh/wrappers/#{app_name}_deploy_wrapper.sh"
    end
  end
  Chef::Log.info("********** The Third deploy::basercms-plugin **********")
end
