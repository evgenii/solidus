### Inatructions
# cap [stage_name] deploy:setup     => init Only first time
# cap [stage_name] deploy:init
# cap [stage_name] deploy
# cap [stage_name] deploy:cold
# cap [stage_name] deploy:restart
#
set :application, 'solidus'

set :repo_url, 'git@github.com:evgenii/solidus.git'

set :branch,    -> { ENV['branch'] || 'master' }
#set :deploy_to, '/var/webapps/solidus'
set :rails_env, 'production'

set :rvm_ruby_version, '2.3.1'

set :keep_releases, 5
set :ssh_options, {
                  keys:          %w(~/.ssh/id_rsa),
                  keepalive:     true,
                  forward_agent: true,
                  auth_methods:  %w(publickey)
                }

set :linked_files, %w(.env.production config/unicorn.rb)
set :linked_dirs, %w(log tmp/pids tmp/sockets public/system public/spree)

set :log_dir, -> { shared_path.join('log') }
set :pid_dir, -> { shared_path.join('tmp/pids') }

set :bundle_without, %w{development test console}.join(' ')

set :assets_dependencies, %w(lib/assets vendor/assets app/assets config/application.rb config/environments Gemfile.lock config/routes.rb)

set :unicorn_config,  -> { current_path.join('config/unicorn.rb') }
set :unicorn_pidfile, -> { fetch(:pid_dir).join('unicorn.pid') }

  set :default_env, -> {
  {
    rails_env: fetch(:rails_env),
    rack_env: fetch(:rails_env)
  }
}

####### UTILS ########
def current_pid(pid_file)
  if test("[ -e #{pid_file} ]")
    pid = capture :cat, pid_file
    if test("kill -0 #{pid}")
      return pid
    else
      execute :rm, '-f', pid_file
    end
  end
  nil
end

def send_signal(signal, pid)
  execute :kill, "-s #{signal}", pid
end


#################################
#            ,%%%,
#       --==% `%%%,
#           |' )`%%,
#           \_/\ @%%,
#            __@@" %%%--"""-.%,
#          /`__|             \%%
#          \\  \   /   |     /'%,
#           \]  | /----'.   < `%,
#               ||       `>> >
#               ||       ///`
#               /(      //(
#################################
namespace :unicorn do
  task :start do
    on roles(:app) do
      within current_path do
        pid = current_pid(fetch(:unicorn_pidfile))
        if pid.nil?
          execute :bundle, 'exec unicorn', "-c #{fetch(:unicorn_config)} -D"
        end
      end
    end
  end

  task :stop do
    on roles(:app) do
      within current_path do
        pid = current_pid(fetch(:unicorn_pidfile))
        send_signal('QUIT', pid) unless pid.nil?
      end
    end
  end

  task :restart do
    invoke 'unicorn:stop'
    invoke 'unicorn:start'
  end

  task :reload do
    on roles(:app) do
      within current_path do
        pid = current_pid(fetch(:unicorn_pidfile))
        if pid.nil?
          invoke 'unicorn:start'
        else
          send_signal('QUIT', pid)
        end
      end
    end
  end
end
namespace :deploy do

  task :setup do
    on roles(:all) do
      invoke 'deploy:check:directories'
      invoke 'deploy:check:linked_dirs'
      invoke 'deploy:check:make_linked_dirs'

      upload! '.env',                      "#{shared_path}/.env.production"
      upload! 'config/unicorn.rb.example', "#{shared_path}/config/unicorn.rb"

      invoke 'deploy:check:linked_files'
    end
  end

  # Rake::Task["migrate"].clear_actions
  # task :migrate do
  #   on roles(:app) do
  #     info '[deploy:migrate] NOOP'
  #     # NOOP
  #   end
  # end
  #
  after :publishing, 'unicorn:reload'
end

namespace :misc do
  desc "Run specified rake task"
  task :run_rake do
    on roles(:all) do
      within release_path do
        execute :rake, ENV['TASK']
      end
    end
  end

  desc "Show environment variables"
  task :printenv do
    on roles(:all) do
      within release_path do
        execute :env
      end
    end
  end
end
