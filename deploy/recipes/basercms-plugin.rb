#
# Cookbook Name:: basercms-plugin
# Recipe:: upload
#

node[:deploy].each do |app_name, deploy|

  Chef::Log.info("********** The First app's initial state is '#{deploy[:deploy_to]}/current/app/Plugin' **********")
#  if ::File.exists?("#{deploy[:deploy_to]}/current/app/Plugin")
    Chef::Log.info("********** The Second app's initial state is '#{node[:basercms_deploy][:plugins]}' **********")
    node[:basercms_deploy][:plugins].each do |plugin|
      if !::File.exists?("#{deploy[:deploy_to]}/current/app/Plugin/#{plugin[:name]}")
        case plugin[:type]
        when 'ssh'
          git_ssh_wrapper app_name do
            owner deploy[:user]
            group deploy[:group]
            ssh_key_data deploy[:scm][:ssh_key]
          end
          git plugin[:name] do
            cwd "#{deploy[:deploy_to]}/current/app/Plugin"
            repo plugin[:repository]
            revision plugin[:branch]
            user deploy[:user]
            group deploy[:group]
            action :checkout
            ssh_wrapper "#{Etc.getpwnam(deploy[:user]).dir}/.ssh/wrappers/#{app_name}_deploy_wrapper.sh"
          end
        when 'https'
          git plugin[:name] do
            cwd "#{deploy[:deploy_to]}/current/app/Plugin"
            repo plugin[:repository]
            revision plugin[:branch]
            user deploy[:user]
            group deploy[:group]
            action :checkout
          end
        else
        end
      end
    end
#  end
  Chef::Log.info("********** The Third app's initial state is '#{node['state']}' **********")

end
