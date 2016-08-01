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
    # lsyncd stop
    lsyncd_target 'from_s3' do
      action :delete
      notifies :stop, 'service[lsyncd]'
    end
    lsyncd_target 'to_s3' do
      action :delete
      notifies :stop, 'service[lsyncd]'
    end
    # Delete Default directory
    directory "#{deploy[:deploy_to]}/current/app/webroot" do
      recursive true
      action :delete
    end
    # Create Empty directory
    directory "#{deploy[:deploy_to]}/current/app/webroot" do
      user deploy[:user]
      action :create
      recursive true
    end
    if !::File.exists?("#{deploy[:home]}/s3sync")
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
      execute "s3 Sync by goofys" do
        command <<-EOH
          goofys #{bucket_name} #{deploy[:home]}/s3sync -o allow_other,--uid=#{uid},--gid=#{gid}
          sleep 30s
        EOH
      end
      # fstab
      mount "#{deploy[:home]}/s3sync" do
        device   "/opt/go/bin/goofys##{bucket_name}"
        pass     0
        dump     0
        fstype   'fuse'
        options  "_netdev,allow_other,--uid=#{uid},--gid=#{gid}"
        action   [:mount, :enable]
      end
    end
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
    if isCreate == true
      execute "git checkout" do
        command "git checkout webroot"
        cwd "#{deploy[:deploy_to]}/current/app"
        user deploy[:user]
      end
    end
  end

end
