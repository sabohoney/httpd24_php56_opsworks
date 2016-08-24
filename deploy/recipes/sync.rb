#
# Cookbook Name:: deploy
# Recipe:: sync
#

recipe_name = 'deploy::sync'

node[:deploy].each do |application, deploy|

  if deploy[:application_type] != 'php' || !node[:opsworks][:instance][:layers].include?('cms')
    Chef::Log.debug("Skipping deploy::sync application #{application} as it is not an PHP app")
    next
  end

  if !node[:app][deploy[:application]].nil? && !node[:app][deploy[:application]].empty? && node[:app][deploy[:application]][:run_recipe].include?(recipe_name)
    custom = node[:app][deploy[:application]]

    # Webroot directry is Re-create.
    directory "#{deploy[:deploy_to]}/current/app/webroot" do
      recursive true
      action :delete
      only_if { File.exists?("#{deploy[:deploy_to]}/current/app/webroot") }
    end
    directory "#{deploy[:deploy_to]}/current/app/webroot" do
      user deploy[:user]
      action :create
      recursive true
      only_if { File.exists?("#{deploy[:deploy_to]}/current/") }
    end
    
    nfsHost = !custom[:nfs_host].nil? ? custom[:nfs_host] : "hogehogehoge"
    if !custom[:sync].nil? && custom[:sync] == 'on'
      # Mount
      mount "#{deploy[:deploy_to]}/current/app/webroot" do
        device   "#{nfsHost}:/srv/www/nfs/current/webroot"
        fstype   'nfs'
        options  "defaults"
        action   [:mount, :enable]
        only_if { File.exists?("#{deploy[:deploy_to]}/current/app/webroot") }
      end
    end
    if !custom[:bucket_name].nil? && !custom[:bucket_name].empty?
      require 'aws-sdk'
      s3 = AWS::S3.new
      bucket_name = custom[:bucket_name]
      include_recipe 'lsyncd'
      lsyncd_target 's3' do
        mode "s3"
        source "#{deploy[:deploy_to]}/current/app/webroot"
        target "s3://#{bucket_name}"
        notifies :restart, 'service[lsyncd]', :delayed
        notifies :create, 'cron[lsyncd_restart]', :delayed
        only_if { s3.buckets[bucket_name].exists? && system("mount |grep #{nfsHost}") && custom[:sync] == 'on' }
      end
      cron "lsyncd_restart" do
        command "/etc/init.d/lsyncd restart"
        minute "*/15"
        action :nothing
      end
      
      execute "AWS S3 Sync" do
        command "aws s3 sync --exact-timestamps s3://#{bucket_name} #{deploy[:deploy_to]}/current/app/webroot"
        user deploy[:user]
        group deploy[:group]
        only_if { s3.buckets[bucket_name].exists? && custom[:is_download] && File.exists?("#{deploy[:deploy_to]}/current/app/webroot") }
      end
    end
  end
end
