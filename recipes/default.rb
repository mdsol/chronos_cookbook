#
# Cookbook Name:: chronos
# Recipe:: default
#
# Copyright (C) 2013 Medidata Solutions, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class ::Chef::Recipe
  include ::Chronos
end

include_recipe 'apt'
include_recipe 'java'
include_recipe 'runit'
include_recipe 'mesos::install'

link '/usr/lib/libmesos.so' do
  to '/usr/local/lib/libmesos.so'
end

directory node['chronos']['home_dir'] do
  owner node['chronos']['user']
  group node['chronos']['group']
  mode 00755
  recursive true
  action :create
end

directory "#{node['chronos']['home_dir']}/environment" do
  owner node['chronos']['user']
  group node['chronos']['group']
  mode 00755
  action :create
end

directory node['chronos']['config_dir'] do
  owner node['chronos']['user']
  group node['chronos']['group']
  mode 00755
  action :create
end

directory node['chronos']['log_dir'] do
  owner node['chronos']['user']
  group node['chronos']['group']
  mode 00755
  action :create
end

remote_file "#{node['chronos']['home_dir']}/chronos.jar" do
  source node['chronos']['jar_source']
  mode '0755'
  not_if { ::File.exists?("#{node['chronos']['home_dir']}/chronos.jar") }
end

command_line_options_array = []

node['chronos']['options'].each_pair do |name, option|
  command = ''
  unless option.nil?
    # Check for boolean options (ie flags with no args)
    if !!option == option
      command = "--#{name}" if option == true
    else
      command = "--#{name} #{option}"
    end
    command_line_options_array << command
  end
end

zk_server_list = []
zk_port = nil
zk_path = nil
zk_master_option = nil
zk_hosts_option = nil

if node['chronos']['zookeeper_server_list'].count > 0
  zk_server_list = node['chronos']['zookeeper_server_list']
  zk_port = node['chronos']['zookeeper_port']
  zk_path = node['chronos']['zookeeper_path']
end

if node['chronos']['zookeeper_exhibitor_discovery'] && !node['chronos']['zookeeper_exhibitor_url'].nil?
  zk_nodes = discover_zookeepers_with_retry(node['chronos']['zookeeper_exhibitor_url'])

  if zk_nodes.nil?
    Chef::Application.fatal!('Failed to discover zookeepers.  Cannot continue')
  end

  zk_server_list = zk_nodes['servers']
  zk_port = zk_nodes['port']
  zk_path = node['chronos']['zookeeper_path']
end

# ZK multi-node syntax: zk://host1:port1,host2:port2,.../path
zk_url_list = []
zk_server_list.each do |zk_server|
  zk_url_list << "#{zk_server}:#{zk_port}"
end

if zk_url_list.count > 0
  zk_master_option = "--master zk://#{zk_url_list.join(',')},/#{zk_path}"
  zk_hosts_option = "--zk_hosts #{zk_url_list.join(',')}"
end

# If we have been able to find zookeeper master endpoint and zookeeper hosts
# then set the command line options we'll be passing to runit
if !zk_master_option.nil? && !zk_hosts_option.nil?
  command_line_options_array << zk_master_option
  command_line_options_array << zk_hosts_option
else
  # if we don't have a user set master or a zk configured master
  # default to local mode.
  if node['chronos']['options']['master'].nil?
    node.override['chronos']['options']['master'] = 'local'
    command_line_options_array << '--master local'
  end
end

if node.attribute?('ec2')
  hostname = "--hostname #{node['ec2']['public_hostname']}"
else
  hostname = "--hostname #{node['ipaddress']}"
end

command_line_options_array << hostname

template "#{node['chronos']['config_dir']}/chronos.conf" do
  source 'chronos.conf.erb'
  owner node['chronos']['user']
  group node['chronos']['group']
  mode 00755
  variables(
    command_line_options: command_line_options_array.join(' '),
  )
  notifies :restart, 'runit_service[chronos]', :delayed
end

runit_service 'chronos'
