#
# Cookbook Name:: deploy
# Recipe:: nfs_setup
# Application nfs
#

node[:deploy].each do |application, deploy|

  if deploy[:application_type] != 'other' && !node[:opsworks][:instance][:layers].include?('nfs')
    Chef::Log.debug("Skipping deploy::nfs_setup application #{application} as it is not an NFS app")
    next
  end

  if !node[:app][deploy[:application]].nil? && !node[:app][deploy[:application]].empty? && deploy[:application] == node[:app][deploy[:application]][:name]
    custom = node[:app][deploy[:application]]
    
    mntDir = "#{deploy[:deploy_to]}/current/webroot"
    directory mntDir do
      user deploy[:user]
      group deploy[:group]
      action :create
      recursive true
      only_if { custom[:is_setup] }
    end
    nfs_export mntDir do
      network '172.31.0.0/16'
      writeable true 
      sync true
      notifies :run, "execute[exportfs]"
      options ['no_root_squash']
      only_if { File.exists?(mntDir) && custom[:is_setup] }
    end
    execute "exportfs" do
      command "exportfs -ra"
      action :nothing
    end
    if !custom[:bucket_name].nil? && !custom[:bucket_name].empty?
      require 'aws-sdk'
      s3 = AWS::S3.new
      bucket_name = custom[:bucket_name]
      execute "AWS S3 Sync" do
        command "aws s3 sync --exact-timestamps s3://#{bucket_name} #{mntDir}"
        user deploy[:user]
        group deploy[:group]
        only_if { s3.buckets[bucket_name].exists? && s3.buckets[bucket_name].objects['index.php'].exists? && File.exists?(mntDir) }
      end
    end
    cookbook_file "/root/custom_metrics.sh" do
      mode '700'
      notifies :create, "cron[custom_metrics]"
    end
    cron "custom_metrics" do
      command "root/custom_metrics.sh"
      minute "*/5"
      action :nothing
    end
  end
end
