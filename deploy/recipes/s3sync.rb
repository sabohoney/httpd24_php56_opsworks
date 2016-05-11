#
# Cookbook Name:: s3sync
# Recipe:: upload
#

node[:deploy].each do |app_name, deploy|

  require 'aws-sdk'
  s3 = AWS::S3.new
  bucket = s3.buckets[node[:basercms_deploy][:bucket_name]]
  if bucket.exists?
    # Go & Goofys Install
    package "golang"
    package "fuse"
    template "/etc/profile.d/go.sh" do
      source "go.sh.erb"
      mode 0644
      user 'root'
      group 'root'
    end
    execute "export" do
      command "export GOPATH=$HOME/go"
      user deploy[:user]
    end
    execute "Download goofys" do
      command "go get github.com/kahing/goofys"
      user deploy[:user]
    end
    execute "Install goofys" do
      command "go install github.com/kahing/goofys"
      user deploy[:user]
    end
    # Mount
    directory "/home/#{deploy[:user]}/s3sync" do
      action :delete
      recursive true
    end
    execute "s3 mount" do
      command "/home/ec2-sftpuser/go/bin/goofys #{node[:basercms_deploy][:bucket_name]} /home/#{deploy[:user]}/s3sync"
    end
    # rsync Configure
    include_recipe 'rsync::server'
    rsync_serve "#{deploy[:deploy_to]}/current" do
      path             "/home/#{deploy[:user]}/s3sync"
      hosts_allow      '127.0.0.1'
      hosts_deny       '0.0.0.0/0'
    end
  end

end
