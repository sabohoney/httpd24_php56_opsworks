#
# Cookbook Name:: deploy
# Recipe:: s3sync
#

node[:deploy].each do |app_name, deploy|

  env = deploy[:environment_variables]
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
      only_if { s3.buckets[bucket_name].exists? && "mount |grep #{env[:nfs_host]}" }
    end
  end

end
