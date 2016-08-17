#
# Cookbook Name:: deploy
# Recipe:: sync
#
app_name = 'basercms'
deploy = node[:deploy][app_name]
mode = !node[:mode].nil? && !node[:mode].empty? ? node[:mode] : "production"
if node[:app][app_name][mode].nil? || node[:app][app_name][mode].empty?
  custom = node[:app][app_name][mode]
  
  nfsHost = !custom[:nfs_host].nil? ? custom[:nfs_host] : "hogehogehoge"
  Chef::Log.info("********** The First deploy::sync **********")
  Chef::Log.info(deploy)
  if !custom[:sync].nil? && custom[:sync] == 'on'
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
      only_if { s3.buckets[bucket_name].exists? && system("mount |grep #{nfsHost}") && custom[:sync] == 'on' }
    end
    
    execute "AWS S3 Sync" do
      command "aws s3 sync --exact-timestamps s3://#{bucket_name} #{deploy[:deploy_to]}/current/app/webroot"
      user deploy[:user]
      group deploy[:group]
      only_if { s3.buckets[bucket_name].exists? && custom[:is_download] }
    end
  end
end
