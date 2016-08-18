
# setup Apache virtual host
node[:deploy].each do |application, deploy|
  include_recipe 'apache2::service'

  if deploy[:application_type] != 'php'
    Chef::Log.debug("Skipping deploy::apache-vhost application #{application} as it is not an PHP app")
    next
  end

  # Any Virtual Host Access Denied
  web_app deploy[:application] do
    docroot '/tmp'
    server_name 'any'
    unless deploy[:domains][1, deploy[:domains].size].empty?
      server_aliases deploy[:domains][1, deploy[:domains].size]
    end
    enable true
  end

  mode = !node[:mode].nil? && !node[:mode].empty? ? node[:mode] : "production"
  require_ip = !node[:app][application][mode][:require_ip].nil? && !node[:app][application][mode][:require_ip].empty? ? node[:app][application][mode][:require_ip] : Array.new
  web_app deploy[:application] do
    docroot deploy[:absolute_document_root]
    server_name deploy[:domains].first
    unless deploy[:domains][1, deploy[:domains].size].empty?
      server_aliases deploy[:domains][1, deploy[:domains].size]
    end
    mounted_at deploy[:mounted_at]
    ssl_certificate_ca deploy[:ssl_certificate_ca]
    allow_override "All"
    enable true
    variables({
      :require_ip => require_ip
    })
  end

  template "#{node[:apache][:dir]}/ssl/#{deploy[:domains].first}.crt" do
    mode 0600
    source 'ssl.key.erb'
    variables :key => deploy[:ssl_certificate]
    notifies :restart, "service[apache2]"
    only_if do
      deploy[:ssl_support]
    end
  end

  template "#{node[:apache][:dir]}/ssl/#{deploy[:domains].first}.key" do
    mode 0600
    source 'ssl.key.erb'
    variables :key => deploy[:ssl_certificate_key]
    notifies :restart, "service[apache2]"
    only_if do
      deploy[:ssl_support]
    end
  end

  template "#{node[:apache][:dir]}/ssl/#{deploy[:domains].first}.ca" do
    mode 0600
    source 'ssl.key.erb'
    variables :key => deploy[:ssl_certificate_ca]
    notifies :restart, "service[apache2]"
    only_if do
      deploy[:ssl_support] && deploy[:ssl_certificate_ca]
    end
  end

  # move away default virtual host so that the new app becomes the default virtual host
  if platform?('ubuntu') && node[:platform_version] == '14.04'
    source_default_site_config = "#{node[:apache][:dir]}/sites-enabled/000-default.conf"
    target_default_site_config = "#{node[:apache][:dir]}/sites-enabled/zzz-default.conf"
  else
    source_default_site_config = "#{node[:apache][:dir]}/sites-enabled/000-default"
    target_default_site_config = "#{node[:apache][:dir]}/sites-enabled/zzz-default"
  end
  execute 'mv away default virtual host' do
    action :run
    command "mv #{source_default_site_config} #{target_default_site_config}"
    notifies :reload, "service[apache2]", :delayed
    only_if do
      ::File.exists?(source_default_site_config)
    end
  end
end
