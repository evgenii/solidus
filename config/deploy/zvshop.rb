server 'evgenii.server.shop',
       user: 'deployer',
       roles: %i{app web db daemon cron}
set :deploy_to, '/var/webapps/solidus'
