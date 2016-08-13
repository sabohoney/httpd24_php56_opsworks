#
# Cookbook Name:: deploy
# Recipe:: nfs_setup
#

node[:deploy].each do |app_name, deploy|

  env = deploy[:environment_variables]
  nfs_export "#{deploy[:deploy_to]}/current" do
    network '172.31.0.0/16'
    writeable true 
    sync true
    options ['no_root_squash']
    only_if { File.exists?("#{node[:deploy][env[:nfs_app]][:deploy_to]}/current") }
  end
  if !env[:bucket_name].nil? && !env[:bucket_name].empty?
    require 'aws-sdk'
    s3 = AWS::S3.new
    bucket_name = env[:bucket_name]
    execute "AWS S3 Sync" do
      command "aws s3 sync --exact-timestamps s3://#{bucket_name} #{deploy[:deploy_to]}/current"
      user deploy[:user]
      group deploy[:group]
      only_if { s3.buckets[bucket_name].exists? && s3.buckets[bucket_name].objects['index.php'].exists? && File.exists?("#{node[:deploy][env[:nfs_app]][:deploy_to]}/current") }
    end
  end

end
