#
# Cookbook Name:: s3sync
# Recipe:: upload
#

node[:deploy].each do |app_name, deploy|

  require 'aws-sdk'
  s3 = AWS::S3.new
  bucket = s3.buckets[deploy[:s3][:name]]
  if !bucket.exists?
    bucket = s3.buckets.create(deploy[:s3][:name])
    bucket.acl = :private
    # Upload
    bucket.upload_file("#{deploy[:deploy_to]}/current")
  end

end
