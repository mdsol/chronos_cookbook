Description
===========

Application cookbook for installing [Chronos][] the fault tolerant job scheduler 
that handles dependencies and iso8601 based schedules.  Chronos was created at 
[Airbnb][] as a replacement for `cron` and runs on the [Apache Mesos][] framework.


Requirements
============

Chef 11.4.0+

This cookbook requires attributes be set based on the instructions for 
[configuring Chronos][]

This cookbook also assumes you will be running a zookeeper cluster in for
production use of Mesos and Chronos.  If you omit zookeeper attributes the 
cookbook does default to the chronos internal zookeeper for test scenarios.

Chronos is a [Dropwizard] application therefore this cookbook exposes some
Dropwizard specific attributes.

The following cookbooks are dependencies:

* apt
* java
* runit (process management)
* mesos (used for installing the mesos libs)
* zookeeper (used for discovering zookeeper ensembles via [Netflix Exhibitor][])

## Platform:

Tested on 

* Ubuntu 12.04


Attributes
==========

* `node['chronos']['home_dir']` - Home installation directory. Default: '/opt/chronos'.
* `node['chronos']['config_dir']` - Configuration file directory. Default: '/etc/chronos/'.
* `node['chronos']['log_dir']` - Log directory. Default: '/var/log/chronos/'.
* `node['chronos']['log_level']` - Dropwizard log level. Default: 'WARN'.
* `node['chronos']['jar_source']` - Jar source location url.
* `node['chronos']['default_job_owner']` - Default email for Chronos jobs. Default: 
'chronos@chronos.io'.
* `node['chronos']['failover_timeout_seconds']` - Failover timeout for the Chronos framework. 
Default: 1200.
* `node['chronos']['failure_retry_delay']` - When a task fails, Chronos will wait up to this 
number of milliseconds to retry. Default: 60000.
* `node['chronos']['disable_after_failures']` - If a job has failed after this many attempts 
since the last success, disable the job. When set to 0, failed jobs are never disabled. 
Default: 0.
* `node['chronos']['schedule_horizon_seconds']` - Horizon (duration) within which jobs 
should be scheduled in advance. Default: 10.
* `node['chronos']['user']` - The user to run tasks as on mesos slaves. Default: 'root'.
* `node['chronos']['webui_port']` - Dropwizard application port. Default: 4400.
* `node['chronos']['admin_port']` - Dropwziard admin port. Default: 4401.

* `node['chronos']['ganglia_host_port']` - If configured, will report metrics to Ganglia 
at the configured interval.
* `node['chronos']['ganglia_group_prefix']` - Group prefix to use for all reported metrics.

* `node['chronos']['mail_from']` - The email address to use for the `From` field.
* `node['chronos']['mail_password']` - The password for mailUser.
* `node['chronos']['mail_server']` - The mail server to use to send notification emails.
* `node['chronos']['mail_user']` - The user to send mail as.
* `node['chronos']['mail_ssl_on']` - Whether or not to enable SSL to send notification emails.

* `node['chronos']['zookeeper_server_list']` - List of zookeeper hostnames or IP addresses. Default: [].
* `node['chronos']['zookeeper_port']` - Mesos master zookeeper port. Default: 2181.
* `node['chronos']['zookeeper_path']` - Mesos master zookeeper path. Default: [].
* `node['chronoso]['zookeeper_state_znode']` - The root znode in which Chronos persists its state. 
Default: '/airbnb/service/chronos/state'.
* `node['chronos']['zookeeper_candidate_znode']` - The root at which all Chronos nodes will register in 
order to form a group. Default: '/airbnb/service/chronos/candidate'.
* `node['chronos']['zookeeper_timeout_ms']` - Timeout for the ZookeeperState abstraction. Default: 5000.

* `node['chronos']['zookeeper_exhibitor_discovery']` - Flag to enable zookeeper ensemble discovery via Netflix Exhibitor. Default: false.
* `node['chronos']['zookeeper_exhibitor_url']` - Netflix Exhibitor zookeeper ensemble url.

* `node['chronos']['mesos_task_cpu']` - Number of CPUs per Mesos task. Default: 1.0.
* `node['chronos']['mesos_task_mem']` - Amount of memory, in MiB, per Mesos task. Default: 1024.
* `node['chronos']['mesos_task_disk']` - Amount of disk space, in MiB, required per Mesos task. Default: 1024.
* `node['chronos']['mesos_role']` - he Mesos role to use for this framework. Default: '\*'.
* `node['chronos']['mesos_checkpoint']` - Enable checkpointing for this framework on Mesos. Default: false.


## Usage

This recipe allows you to deploy Airbnb's Chronos in a minimal test mode using an internal zookeeper running 
within Chronos itself.
WARNING: Do not use this configuration for production deployments!

Here is a sample role for creating a Chronos node with an internal zookeeper:
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
    version: 0.14.0
run_list:
  recipe[chronos]
```


This recipe allows you to deploy Airbnb's Chronos in production using a seperate zookeeper ensemble.
NOTE: This is a recommended way to deploy Chronos in production.

Here is a sample role for creating a Chronos node with a seperate zookeeper ensemble:
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
    version: 0.14.0
run_list:
  recipe[chronos]
```


This recipe allows you to deploy Airbnb's Chronos in production using Netflix Exhibitor's 
discovery zookeeper service.
NOTE: This is a recommended way to deploy Chronos in production.

Here is a sample role for creating a Chronos node with a seperate zookeeper ensemble:
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
    version: 0.14.0
run_list:
  recipe[chronos]
```

[Chronos]: http://nerds.airbnb.com/introducing-chronos
[Airbnb]: http://www.airbnb.com
[Apache Mesos]: http://http://mesos.apache.org
[configuring Chronos]: https://github.com/airbnb/chronos/blob/master/config/README.md
[Netflix Exhibitor]: https://github.com/Netflix/exhibitor
[Dropwizard]: http://dropwizard.codahale.com

## Author

* Author: [Ray Rodriguez](https://github.com/rayrod2030)
