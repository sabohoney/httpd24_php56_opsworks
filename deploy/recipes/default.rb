include_recipe 'dependencies'

node[:deploy].each do |application, deploy|

  opsworks_deploy_user do
    deploy_data deploy
  end
  execute "git checkout" do
    command "groupadd deploy"
  end

end