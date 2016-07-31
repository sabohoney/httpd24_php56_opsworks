#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
package "git"
package "curl"
package "bash-completion"
package "vim-enhanced"
package "gd"
package "ImageMagick"
package "fuse"

#
# Completion
#
template "/etc/profile.d/completion.sh" do
    source "completion.sh.erb"
    mode 0644
    user 'root'
    group 'root'
end
