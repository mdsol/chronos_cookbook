Chronos Cookbook
==============
[![Build Status](https://secure.travis-ci.org/mdsol/chronos_cookbook.png?branch=master)](http://travis-ci.org/mdsol/chronos_cookbook)

Description
===========

Application cookbook for installing [Chronos][] the fault tolerant job scheduler 
that handles dependencies and iso8601 based schedules.  Chronos was created at 
[Airbnb][] as a replacement for `cron` and runs on the [Apache Mesos][] 
framework.


Requirements
============

Chef 11.4.0+

This cookbook requires attributes be set based on the instructions for 
[configuring Chronos][]

This cookbook also assumes you will be running a zookeeper cluster in for
production use of Mesos and Chronos.  If you omit zookeeper attributes the 
cookbook does default to the chronos internal zookeeper for test scenarios.

The following cookbooks are dependencies:

* apt
* java
* runit (process management)
* mesos (used for installing the Mesos libraries)
* zookeeper (used for discovering zookeeper ensembles via [Netflix Exhibitor][])

## Platform:

Tested on 

* Ubuntu 12.04

This cookbook includes cross-platform testing support via `test-kitchen`, see 
`TESTING.md`.


Attributes
==========

* `node['chronos']['home_dir']` - Home installation directory. Default: 
'/opt/chronos'.
* `node['chronos']['config_dir']` - Configuration file directory. Default: 
'/etc/chronos/'.
* `node['chronos']['log_dir']` - Log directory. Default: '/var/log/chronos/'.
* `node['chronos']['jar_source']` - Jar source location url.
* `node['chronos']['user']` - The mesos user to run the processes under. 
Default: 'root'.
* `node['chronos']['group']` - The group to run tasks as on mesos slaves. 
Default: 'root'.

* `node['chronos']['options']['default_job_owner']` - Default email for Chronos 
jobs.  Default: 'flo@mesosphe.re'.
* `node['chronos']['options']['disable_after_failures']` - Disables a job after 
this many failures have occurred. Default: 0.
* `node['chronos']['options']['failover_timeout']` - The failover timeout in 
seconds for Mesos. Default: 1200.
* `node['chronos']['options']['failure_retry]` - Number of ms between retries. 
Default: 60000.
* `node['chronos']['options']['ganglia_group_prefix']` - Group prefix to use 
for all reported metrics.
* `node['chronos']['options']['ganglia_host_port']` - If configured, will 
report metrics to Ganglia at the configured interval.
* `node['chronos']['options']['ganglia_reporting_interval']` - Ganglia 
reporting interval (seconds). Default: 60.
* `node['chronos']['options']['hostname']` - The advertised hostname stored in 
ZooKeeper so another standby host can redirect to this elected leader.(default 
= ipv4 for non-EC2 instance.  Public DNS for EC2 instance).
* `node['chronos']['options']['http_credentials']` - Credentials for accessing 
the http service.  If empty, anyone can access the HTTP endpoint. A 
username:password is expected where the username must not contain ':'.
* `node['chronos']['options']['http_endpoints']` - The URLs of the event 
endpoints master.
* `node['chronos']['options']['http_port']` - The port to listen on for HTTP 
requests (default = 8080).
* `node['chronos']['options']['https_port']` - The port to listen on for HTTPS 
requests (default = 8081).
* `node['chronos']['options']['leader_max_idle_time']` - The look-ahead time 
for scheduling tasks in milliseconds.  Default: 5000.
* `node['chronos']['options']['log_config']` - The path to the log config.
* `node['chronos']['options']['mail_from']` - Mail from field.
* `node['chronos']['options']['mail_password']` - Mail password (for auth).
* `node['chronos']['options']['mail_server']` - Address of the mail server.
* `node['chronos']['options']['mail_ssl']` - Mail SSL. Default: false
* `node['chronos']['options']['mail_user']` - Mail user (for auth).
* `node['chronos']['options']['master']` - The URL of the Mesos master.  
Cookbook will default this to 'local' if no zookeeper configuration is defined 
and this attribute is not set.
* `node['chronos']['options']['checkpoint']` - Enable checkpointing of tasks. 
Request checkpointing enabled on slaves.  Allows tasks to continue running 
during mesos-slave restarts and upgrades. Default: false.
* `node['chronos']['options']['mesos_framework_name']` - The framework name. 
Default: 'chronos-{version}'
* `node['chronos']['options']['mesos_role']` - The Mesos role to run tasks 
under. Default: '*'.
* `node['chronos']['options']['ssl_keystore_password']` - The password for the
keystore.
* `node['chronos']['options']['ssl_keystore_path']` - Provides the keystore, if
supplied, SSL is enabled.
* `node['chronos']['options']['mesos_task_cpu']` - Number of CPUs to request 
from Mesos for each task. Default: 0.1.
* `node['chronos']['options']['mesos_task_disk']` - Amount of disk capacity to 
request from Mesos for each task (MB). Default: 256.
* `node['chronos']['options']['mesos_task_mem']` - Amount of memory to request 
from Mesos for each task (MB).  Default: 128.
* `node['chronos']['options']['schedule_horizon']` - The look-ahead time for 
scheduling tasks in seconds.  Default: 60.
* `node['chronos]['options']['zk_path']` - The root znode in which Chronos 
persists its state. Default: 'chronos'.
* `node['chronos']['options']['zk_timeout']` - Timeout for the ZookeeperState 
abstraction in milliseconds. Default: 10000.

* `node['chronos']['zookeeper_server_list']` - List of zookeeper hostnames or 
IP addresses. Default: [].
* `node['chronos']['zookeeper_port']` - Mesos master zookeeper port. 
Default: 2181.
* `node['chronos']['zookeeper_path']` - Mesos master zookeeper path. 
Default: [].
* `node['chronos']['zookeeper_exhibitor_discovery']` - Flag to enable zookeeper 
ensemble discovery via Netflix Exhibitor. Default: false.
* `node['chronos']['zookeeper_exhibitor_url']` - Netflix Exhibitor zookeeper 
ensemble url.


## Usage

Here are some sample roles for configuring running Chronos in internal test 
mode and in zookeeper backed production mode.

Here is a sample role for creating a Chronos node with an internal zookeeper:
WARNING: Do not use this configuration for production deployments!

```YAML
chef_type:           role
default_attributes:
description:
env_run_lists:
json_class:          Chef::Role
name:                chronos
override_attributes:
  chronos:
    jar_source: 'JAR_SOURCE_URL_HERE'
  mesos:
    version: 0.15.0
run_list:
  recipe[chronos]
```

Here is a sample role for creating a Chronos node with a seperate zookeeper 
ensemble:
NOTE: This is a recommended way to deploy Chronos in production.
```YAML
chef_type:           role
default_attributes:
description:
env_run_lists:
json_class:          Chef::Role
name:                chronos
override_attributes:
  chronos:
    jar_source: 'JAR_SOURCE_URL_HERE'
    zookeeper_server_list: [ '203.0.113.2', '203.0.113.3', '203.0.113.4' ]
    zookeeper_port: 2181
    zookeeper_path: 'mesos'
  mesos:
    version: 0.15.0
run_list:
  recipe[chronos]
```

Here is a sample role for creating a Chronos node with a seperate zookeeper 
ensemble dynamically discovered via Netflix Exhibitor:
NOTE: This is a recommended way to deploy Chronos in production.
```YAML
chef_type:           role
default_attributes:
description:
env_run_lists:
json_class:          Chef::Role
name:                chronos
override_attributes:
  chronos:
    jar_source: 'JAR_SOURCE_URL_HERE'
    zookeeper_path: 'mesos'
    zookeeper_exhibitor_discovery: true
    zookeeper_exhibitor_url: 'http://zk-exhibitor-endpoint.example.com:8080'
  mesos:
    version: 0.15.0
run_list:
  recipe[chronos]
```

[Chronos]: http://nerds.airbnb.com/introducing-chronos
[Airbnb]: http://www.airbnb.com
[Apache Mesos]: http://http://mesos.apache.org
[configuring Chronos]: https://github.com/airbnb/chronos/blob/master/config/README.md
[Netflix Exhibitor]: https://github.com/Netflix/exhibitor

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

## License and Author

* Author: [Ray Rodriguez](https://github.com/rayrod2030)

Copyright 2013 Medidata Solutions Worldwide

Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
this file except in compliance with the License. You may obtain a copy of the 
License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed 
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR 
CONDITIONS OF ANY KIND, either express or implied. See the License for the 
specific language governing permissions and limitations under the License.
