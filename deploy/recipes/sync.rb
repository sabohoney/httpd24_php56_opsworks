#
# Cookbook Name:: deploy
# Recipe:: sync
#

node[:deploy].each do |app_name, deploy|

  env = deploy[:environment_variables]
  mode = !env[:mode].nil? ? env[:mode] : "none"
  nfsHost = !env[:nfs_host].nil? ? env[:nfs_host] : "hogehogehoge"
  Chef::Log.info("********** The First deploy::sync **********")
  if !env[:sync].nil? && env[:sync].equal?("on")
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
      device   "#{env[:nfs_host]}:/srv/www/nfs/current/webroot"
      action   :umount
    end
    mount "#{deploy[:deploy_to]}/current/app/webroot" do
      device   "#{env[:nfs_host]}:/srv/www/nfs/current/webroot"
      fstype   'nfs'
      options  "defaults"
      action   [:mount, :enable]
    end
  end
  if !env[:bucket_name].nil? && !env[:bucket_name].empty?
    require 'aws-sdk'
    s3 = AWS::S3.new
    bucket_name = env[:bucket_name]
    include_recipe 'lsyncd'
    lsyncd_target 's3' do
      mode "s3"
      source "#{deploy[:deploy_to]}/current/app/webroot"
      target "s3://#{bucket_name}"
      notifies :restart, 'service[lsyncd]', :delayed
      only_if { s3.buckets[bucket_name].exists? && system("mount |grep #{nfsHost}") && mode.equal?("production") }
    end
    
    execute "AWS S3 Sync" do
      command "aws s3 sync --exact-timestamps s3://#{bucket_name} #{deploy[:deploy_to]}/current/app/webroot"
      user deploy[:user]
      group deploy[:group]
      only_if { s3.buckets[bucket_name].exists? && mode.equal?("staging") }
    end
  end

end
