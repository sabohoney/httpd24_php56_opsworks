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
    directory "/home/#{deploy[:user]}/s3sync" do
      user deploy[:user]
      group deploy[:user]
      action :create
      recursive true
    end
    # Mount
    execute "export" do
      command <<-EOH
        export GOPATH=$HOME/go
        go get github.com/kahing/goofys
        go install github.com/kahing/goofys
        ~/go/bin/goofys #{node[:basercms_deploy][:bucket_name]} /home/#{deploy[:user]}/s3sync
      EOH
    end
    # rsync Configure
    include_recipe 'rsync::server'
    rsync_serve "/home/#{deploy[:user]}/s3sync" do
      path "#{deploy[:deploy_to]}/current/app/webroot"
    end
  end

end
