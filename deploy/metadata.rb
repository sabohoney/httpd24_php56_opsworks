name        "deploy"
description "Deploy applications"
maintainer  "Studio Arcana co.,Ltd."
license     "Apache 2.0"
version     "1.0.0"

depends "dependencies"
depends "scm_helper"
depends "apache2"
depends "ssh_users"
depends "opsworks_agent_monit"
depends "php"
depends "mysql"
depends "golang"
depends "lsyncd"
depends "git_ssh_wrapper"
depends "composer"

recipe "deploy::php-deploy", "Deploy a PHP application"
recipe "deploy::basercms-deploy", "Basic Configuration for BaserCMS"
