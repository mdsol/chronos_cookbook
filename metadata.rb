name             'chronos'
maintainer       'Medidata Solutions'
maintainer_email 'rarodriguez@mdsol.com'
license          'Apache 2.0'
description      'Installs/Configures Chronos'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.1'

supports 'ubuntu'

depends 'apt',       '~> 2.3'
depends 'java',      '~> 1.22'
depends 'mesos',     '~> 1.0'
depends 'runit',     '~> 1.5'
depends 'zookeeper', '~> 1.6'
