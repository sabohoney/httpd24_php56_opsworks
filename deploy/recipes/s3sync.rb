#
# Cookbook Name:: s3sync
# Recipe:: upload
#

node[:deploy].each do |app_name, deploy|

  require 'aws-sdk'
  s3 = AWS::S3.new
  bucket = s3.buckets[node[:basercms_deploy][:bucket_name]]
  if bucket.exists?
    # rsync Configure
    include_recipe 'rsync::server'
    rsync_serve "#{deploy[:deploy_to]}/current" do
      path             "/home/#{deploy[:user]}/s3sync"
      hosts_allow      '127.0.0.1'
      hosts_deny       '0.0.0.0/0'
    end
  end

end
