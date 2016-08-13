#
# Cookbook Name:: deploy
# Recipe:: nfs_setup
#

node[:deploy].each do |app_name, deploy|

  env = deploy[:environment_variables]
  mntDir = "#{deploy[:deploy_to]}/current/webroot"
  directory mntDir do
    user deploy[:user]
    group deploy[:group]
    action :create
    recursive true
  end
  nfs_export mntDir do
    network '172.31.0.0/16'
    writeable true 
    sync true
    options ['no_root_squash']
    only_if { File.exists?(mntDir) }
  end
  if !env[:bucket_name].nil? && !env[:bucket_name].empty?
    require 'aws-sdk'
    s3 = AWS::S3.new
    bucket_name = env[:bucket_name]
    execute "AWS S3 Sync" do
      command "aws s3 sync --exact-timestamps s3://#{bucket_name} #{mntDir}"
      user deploy[:user]
      group deploy[:group]
      only_if { s3.buckets[bucket_name].exists? && s3.buckets[bucket_name].objects['index.php'].exists? && File.exists?(mntDir) }
    end
  end

end
