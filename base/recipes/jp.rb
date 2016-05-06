#
# Cookbook Name:: base
# Recipe:: jst
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
bash "Change Localtime" do
  code <<-EOL
    rm /etc/localtime
    ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
  EOL
end

template "/etc/sysconfig/clock" do
    source "clock.erb"
    mode 0644
    user 'root'
    group 'root'
end