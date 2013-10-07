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

include_recipe 'apt'
include_recipe 'java'
include_recipe 'runit'
include_recipe 'mesos::install'

link '/usr/lib/libmesos.so' do
  to '/usr/local/lib/libmesos.so'
end

directory node['chronos']['home_dir'] do
  owner 'root'
  group 'root'
  mode 00755
  recursive true
  action :create
end

directory "#{node['chronos']['home_dir']}/environment" do
  owner 'root'
  group 'root'
  mode 00755
  action :create
end

directory node['chronos']['config_dir'] do
  owner 'root'
  group 'root'
  mode 00755
  action :create
end

directory node['chronos']['log_dir'] do
  owner 'root'
  group 'root'
  mode 00755
  action :create
end

remote_file "#{node['chronos']['home_dir']}/chronos.jar" do
  source "#{node['chronos']['jar_source']}"
  mode '0755'
  not_if { ::File.exists?("#{node['chronos']['home_dir']}/chronos.jar") }
end

zk_server_list = []
zk_port = nil
zk_path = nil

if node['chronos']['zookeeper_server_list'].count > 0
  zk_server_list = node['chronos']['zookeeper_server_list']
  zk_port = node['chronos']['zookeeper_port']
  zk_path = node['chronos']['zookeeper_path']
end

if node['chronos']['zookeeper_exhibitor_discovery'] && !node['chronos']['zookeeper_exhibitor_url'].nil?
  zk_nodes = discover_zookeepers(node['chronos']['zookeeper_exhibitor_url'])

  zk_server_list = zk_nodes['servers']
  zk_port = zk_nodes['port']
  zk_path = node['chronos']['zookeeper_path']
end

template "#{node['chronos']['config_dir']}/chronos.yml" do
  source 'chronos.yml.erb'
  owner 'root'
  group 'root'
  mode 00755
  variables(
    :zookeeper_server_list => zk_server_list,
    :zookeeper_port => zk_port,
    :zookeeper_path => zk_path
  )
  notifies :restart, "runit_service[chronos]", :delayed
end

runit_service 'chronos'
