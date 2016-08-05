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
    if !::File.exists?("#{deploy[:deploy_to]}/current/app/webroot/index.php")
      # Mount
      uid = '4000'#%x(id -u deploy)
      gid = '48'#%x(id -g apache)
      execute "s3 Sync by goofys" do
        command <<-EOH
          goofys #{bucket_name} #{deploy[:deploy_to]}/current/app/webroot -o allow_other,--uid=#{uid},--gid=#{gid}
          sleep 30s
        EOH
      end
      # fstab
      mount "#{deploy[:deploy_to]}/current/app/webroot" do
        device   "/opt/go/bin/goofys##{bucket_name}"
        pass     0
        dump     0
        fstype   'fuse'
        options  "_netdev,allow_other,--uid=#{uid},--gid=#{gid}"
        action   [:mount, :enable]
      end
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
