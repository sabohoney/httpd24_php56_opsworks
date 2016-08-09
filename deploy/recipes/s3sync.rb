#
# Cookbook Name:: deploy
# Recipe:: s3sync
#

node[:deploy].each do |app_name, deploy|

  if !deploy[:environment_variables][:bucket_name].nil? && !deploy[:environment_variables][:bucket_name].empty?
    require 'aws-sdk'
    s3 = AWS::S3.new
    bucket_name = deploy[:environment_variables][:bucket_name]
    if s3.buckets[bucket_name].exists?
      if s3.buckets[bucket_name].objects['index.php'].exists?
        isCreate = false;
      else
        isCreate = true;
      end
    else
      isCreate = true;
      s3.buckets.create(bucket_name)
    end
    include_recipe 'lsyncd'
    lsyncd_target 's3' do
      mode "s3"
      source "#{deploy[:deploy_to]}/current/app/webroot"
      target "s3://#{bucket_name}"
      notifies :restart, 'service[lsyncd]', :delayed
    end
  end

end
