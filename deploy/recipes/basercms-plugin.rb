#
# Cookbook Name:: basercms-plugin
# Recipe:: upload
#
include_recipe 'deploy'

node[:deploy].each do |app_name, deploy|

  if app_name == "basercms"
    Chef::Log.info("********** The First deploy::basercms-plugin **********")
    if ::File.exists?(deploy[:home])
      Chef::Log.info("********** The Second deploy::basercms-plugin **********")
      if !node[:basercms_deploy][:plugin].nil?
        if !::File.exists?("#{deploy[:deploy_to]}/current/app/Plugin")
          git_ssh_wrapper app_name do
            owner deploy[:user]
            group deploy[:group]
            ssh_key_data deploy[:scm][:ssh_key]
          end
          git "#{deploy[:deploy_to]}/current/app/Plugin" do
            repo node[:basercms_deploy][:plugin]
            revision 'master'
            user deploy[:user]
            group deploy[:group]
            action :checkout
            ssh_wrapper "#{Etc.getpwnam(deploy[:user]).dir}/.ssh/wrappers/#{app_name}_deploy_wrapper.sh"
          end
        end
      elsif !node[:basercms_deploy][:plugins].nil?
        node[:basercms_deploy][:plugins].each do |plugin|
          if !::File.exists?("#{deploy[:deploy_to]}/current/app/Plugin/#{plugin[:name]}")
            case plugin[:type]
            when 'ssh'
              git_ssh_wrapper app_name do
                owner deploy[:user]
                group deploy[:group]
                ssh_key_data deploy[:scm][:ssh_key]
              end
              git "#{deploy[:deploy_to]}/current/app/Plugin/#{plugin[:name]}" do
                repo plugin[:repository]
                revision plugin[:branch]
                user deploy[:user]
                group deploy[:group]
                action :checkout
                ssh_wrapper "#{Etc.getpwnam(deploy[:user]).dir}/.ssh/wrappers/#{app_name}_deploy_wrapper.sh"
              end
            when 'https'
              git "#{deploy[:deploy_to]}/current/app/Plugin/#{plugin[:name]}" do
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
      end
    end
    Chef::Log.info("********** The Third deploy::basercms-plugin **********")
  end

end
