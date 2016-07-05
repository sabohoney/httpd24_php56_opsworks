#
# Cookbook Name:: s3sync
# Recipe:: upload
#

node[:deploy].each do |app_name, deploy|

  require 'aws-sdk'
  s3 = AWS::S3.new
  if s3.buckets[node[:basercms_deploy][:bucket_name]].exists?
    isCreate = false;
  else
    isCreate = true;
    s3.buckets.create(node[:basercms_deploy][:bucket_name])
  end
  # Go & Goofys Install
#   package "golang"
  package "fuse"
#   template "/etc/profile.d/go.sh" do
#     source "go.sh.erb"
#     mode 0644
#     user 'root'
#     group 'root'
#   end
  directory "#{deploy[:deploy_to]}/current/app/webroot" do
    recursive true
    action :delete
  end
  directory "#{deploy[:deploy_to]}/current/app/webroot" do
    user deploy[:user]
    action :create
    recursive true
  end
  directory "#{deploy[:home]}/s3sync" do
    recursive true
    action :delete
  end
  directory "#{deploy[:home]}/s3sync" do
    user deploy[:user]
    group deploy[:group]
    action :create
    recursive true
  end
  # Mount
  uid = '4000'#%x(id -u deploy)
  gid = '48'#%x(id -g apache)
  # lsync
  lsyncd_target 'from_s3' do
    source "#{deploy[:home]}/s3sync"
    target "#{deploy[:deploy_to]}/current/app/webroot"
    rsync_opts ["-a"]
    notifies :restart, 'service[lsyncd]', :delayed
  end
  lsyncd_target 'to_s3' do
    source "#{deploy[:deploy_to]}/current/app/webroot"
    target "#{deploy[:home]}/s3sync"
    rsync_opts ["-a"]
    notifies :restart, 'service[lsyncd]', :delayed
  end
  execute "s3 Sync by goofys" do
    command <<-EOH
      goofys #{node[:basercms_deploy][:bucket_name]} #{deploy[:home]}/s3sync -o allow_other,--uid=#{uid},--gid=#{gid}
      sleep 30s
    EOH
  end
  if isCreate == true
    execute "git checkout" do
      command "git checkout webroot"
      cwd "#{deploy[:deploy_to]}/current/app"
      user deploy[:user]
    end
#     execute "Add write-access permission to storage directory" do
#       command "chown -R apache:#{deploy[:group]} #{deploy[:deploy_to]}/current/app"
#     end
#   
#     # Add write-access permission to "shared/log" directory.
#     execute "Add write-access permission to storage directory" do
#       command "chmod -R g+w #{deploy[:deploy_to]}/current/app"
#     end
  end
  # fstab
  mount "#{deploy[:home]}/s3sync" do
    device   "/opt/go/bin/goofys##{node[:basercms_deploy][:bucket_name]}"
    pass     0
    dump     0
    fstype   'fuse'
    options  "_netdev,allow_other,--uid=#{uid},--gid=#{gid}"
    action   [:mount, :enable]
  end

end
