#
# Cookbook Name:: deploy
# Recipe:: basercms-deploy
#

node[:deploy].each do |app_name, deploy|

  mode = !node[:mode].nil? && !node[:mode].empty? ? node[:mode] : "production"
  if node[:app][app_name][mode].nil? || node[:app][app_name][mode].empty?
    next
  end
  custom = node[:app][app_name][mode]
  if !deploy[:environment_variables][:type].nil? && deploy[:environment_variables][:type] == "basercms"
    Chef::Log.info("********** The Start deploy::basercms **********")
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

    # Plugin
    if ::File.exists?(deploy[:home])
      Chef::Log.info("********** The Start plugin **********")
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
      Chef::Log.info("********** The End plugin **********")
    end

    # Mount
    nfsHost = !custom[:nfs_host].nil? ? custom[:nfs_host] : "hogehogehoge"
    if !custom[:sync].nil? && custom[:sync] == 'on'
      Chef::Log.info("********** The Start Mount **********")
      directory "#{deploy[:deploy_to]}/current/app/webroot" do
        recursive true
        action :delete
      end
      directory "#{deploy[:deploy_to]}/current/app/webroot" do
        user deploy[:user]
        action :create
        recursive true
      end
      # Mount
      mount "#{deploy[:deploy_to]}/current/app/webroot" do
        device   "#{nfsHost}:/srv/www/nfs/current/webroot"
        fstype   'nfs'
        options  "defaults"
        action   [:mount, :enable]
      end
      Chef::Log.info("********** The End Mount **********")
    end
    # s3 Sync
    if !custom[:bucket_name].nil? && !custom[:bucket_name].empty?
      Chef::Log.info("********** The Start Sync **********")
      require 'aws-sdk'
      s3 = AWS::S3.new
      bucket_name = custom[:bucket_name]
      include_recipe 'lsyncd'
      lsyncd_target 's3' do
        mode "s3"
        source "#{deploy[:deploy_to]}/current/app/webroot"
        target "s3://#{bucket_name}"
        notifies :restart, 'service[lsyncd]', :delayed
        only_if { s3.buckets[bucket_name].exists? && system("mount |grep #{nfsHost}") && custom[:sync] == 'on' }
      end

      execute "AWS S3 Sync" do
        command "aws s3 sync --exact-timestamps s3://#{bucket_name} #{deploy[:deploy_to]}/current/app/webroot"
        user deploy[:user]
        group deploy[:group]
        only_if { s3.buckets[bucket_name].exists? && custom[:is_download] }
      end
      Chef::Log.info("********** The End Sync **********")
    end

    Chef::Log.info("********** The End deploy::basercms **********")
  end

end
