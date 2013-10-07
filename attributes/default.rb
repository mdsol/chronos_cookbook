default['chronos']['home_dir']                      = '/opt/chronos'
default['chronos']['config_dir']                    = '/etc/chronos'
default['chronos']['log_dir']                       = '/var/log/chronos'
default['chronos']['log_level']                     = 'WARN'
default['chronos']['jar_source']                    = nil
default['chronos']['default_job_owner']             = 'chronos@chronos.io'
default['chronos']['failover_timeout_seconds']      = 1200
default['chronos']['failure_retry_delay']           = 60000
default['chronos']['disable_after_failures']        = 0
default['chronos']['schedule_horizon_seconds']      = 10
default['chronos']['user']                          = 'root'
default['chronos']['webui_port']                    = 4400
default['chronos']['admin_port']                    = 4401

default['chronos']['ganglia_host_port']             = nil
default['chronos']['ganglia_group_prefix']          = nil

default['chronos']['mail_from']                     = nil
default['chronos']['mail_password']                 = nil
default['chronos']['mail_server']                   = nil
default['chronos']['mail_user']                     = nil
default['chronos']['mail_ssl_on']                   = nil

default['chronos']['zookeeper_server_list']         = []
default['chronos']['zookeeper_port']                = 2181
default['chronos']['zookeeper_path']                = 'mesos'
default['chronos']['zookeeper_state_znode']         = '/airbnb/service/chronos/state'
default['chronos']['zookeeper_candidate_znode']     = '/airbnb/service/chronos/candidate'
default['chronos']['zookeeper_timeout_ms']          = 5000

default['chronos']['zookeeper_exhibitor_discovery'] = false
default['chronos']['zookeeper_exhibitor_url']       = nil

default['chronos']['mesos_task_cpu']                = 1.0
default['chronos']['mesos_task_mem']                = 1024
default['chronos']['mesos_task_disk']               = 1024
default['chronos']['mesos_role']                    = '*'
default['chronos']['mesos_checkpoint']              = false

