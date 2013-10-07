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

template "#{node['chronos']['config_dir']}/chronos.yml" do
  source 'scheduler.yml.erb'
end

runit_service 'chronos'

