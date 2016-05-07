#
# Cookbook Name:: deploy
# Recipe:: basercms-deploy
#

node[:deploy].each do |app_name, deploy|

  if ::File.exists?("#{deploy[:deploy_to]}/current/app")
    # Add write-access permission to "shared/log" directory.
    execute "Add write-access permission to storage directory" do
      command "chown -R apache:#{deploy[:group]} #{deploy[:deploy_to]}/current"
    end
  
    # Add write-access permission to "shared/log" directory.
    execute "Add write-access permission to storage directory" do
      command "chmod -R g+w #{deploy[:deploy_to]}/current"
    end
  end

end
