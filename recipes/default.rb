#
# Cookbook Name:: apache2-wrapper
# Recipe:: default
#
# Copyright 2014, Naoya Nakazawa
#
# All rights reserved - Do Not Redistribute
#

#
# Apache2
#
include_recipe 'apache2'
include_recipe 'apache2::mod_rewrite'

cookbook_file '/etc/sysconfig/httpd' do
  source 'httpd.sysconfig'
  notifies :run, 'execute[httpd-stop-start]', :immediately
  only_if { node[:platform] == 'centos' and node['apache2-wrapper']['httpd'] == 'worker' }
end

execute 'httpd-stop-start' do
  command 'service httpd stop && sleep 1 && service httpd start'
  action :nothing
end

apache_site '000-default' do
  enable false
end

template '/etc/apache2/envvars' do
  mode 0644
  source 'apache2-envvars.erb'
  only_if { ::FileTest.directory?('/etc/apache2') }
end

file "#{node['apache']['dir']}/conf.d/other-vhosts-access-log" do
  action :delete
  notifies :restart, resources(:service => 'apache2')
end

%w{
  001-default
  010-mpm
  050-status
}.each do |conf|
  web_app conf do
    port, name = conf.split('-', 2)
    case name
    when 'status'
      @params[:server_info] = true
      @params[:server_status] = true
    end

    cookbook 'apache2-wrapper'
    template "httpd-#{conf}.conf.erb"
  end
end


#
# mod_log_rotate
#
package 'mod_log_rotate' do
  notifies :run, 'execute[generate-module-list]', :immediately
  action :install
end

apache_module 'log_rotate' do
  conf true
end


#
# Index page
#
file "#{node['apache']['docroot_dir']}/index.html" do
  content node[:fqdn]
  action :create
end


#
# Packages
#
%w{
  cronolog
  lynx
  mod_log_rotate
}.each do |pkg, ver|
  package pkg do
    action :install
    version ver if ver && ver.length > 0
  end
end


#
# cron
#
file '/etc/logrotate.d/httpd' do
  action :delete
end

cron 'apache2-wrapper-delete-log' do
  command "find #{node['apache']['log_dir']} -type f -mtime +30 -delete"
  hour 5
  minute 0
  action :create
end
