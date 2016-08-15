#
# Cookbook Name:: deploy
# Recipe:: s3sync
#

node[:deploy].each do |app_name, deploy|

  env = deploy[:environment_variables]
  mode = !env[:mode].nil? ? env[:mode] : "none"
  Chef::Log.info("********** The First deploy::s3sync **********")
  Chef::Log.info(env)
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
      only_if { s3.buckets[bucket_name].exists? && system("mount |grep #{env[:nfs_host]}") && mode.equal?("production") }
    end
    
    execute "AWS S3 Sync" do
      command "aws s3 sync --exact-timestamps s3://#{bucket_name} #{deploy[:deploy_to]}/current/app/webroot"
      user deploy[:user]
      group deploy[:group]
      only_if { s3.buckets[bucket_name].exists? && mode.equal?("staging") }
    end
  end

end
