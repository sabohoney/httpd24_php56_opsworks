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
    execute "export" do
      command <<-EOH
        export GOPATH=$HOME/go
        go get github.com/kahing/goofys
        go install github.com/kahing/goofys
        ~/go/bin/goofys #{node[:basercms_deploy][:bucket_name]} #{deploy[:deploy_to]}/current/app/webroot
        sleep 30s
      EOH
    end
#     execute "git checkout" do
#       command "git checkout webroot"
#       cwd "#{deploy[:deploy_to]}/current/app"
#       user deploy[:user]
    end
    execute "Add write-access permission to storage directory" do
      command "chown -R apache:#{deploy[:group]} #{deploy[:deploy_to]}/current/app"
    end
  
    # Add write-access permission to "shared/log" directory.
    execute "Add write-access permission to storage directory" do
      command "chmod -R g+w #{deploy[:deploy_to]}/current/app"
    end
  end

end
