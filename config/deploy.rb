# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'rollfindr'
set :repo_url, 'git@bitbucket.org:/rollfindr/rollfindr.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/rollfindr'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
set :default_env, {
  'EXECJS_RUNTIME' => 'Node',
  'JRUBY_OPTS' => '-X-C'
}

set :rvm_ruby_version, 'jruby-1.7.17'

# Default value for keep_releases is 5
set :keep_releases, 3

set :puma_rackup, -> { File.join(current_path, 'config.ru') }
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_conf, "#{shared_path}/puma.rb"
set :puma_access_log, "#{shared_path}/log/puma_error.log"
set :puma_error_log, "#{shared_path}/log/puma_access.log"
set :puma_role, :app
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
set :puma_threads, [0, 16]
set :puma_workers, 0
set :puma_init_active_record, true
set :puma_preload_app, true
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }


set :default_shell, '/bin/bash -l'

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  task :source_env do
    on roles(:app) do
      execute "source /var/www/rollfindr/.env"
    end
  end

  task :fix_socket_permissions do
    on roles(:app) do
      execute "chmod 777 #{shared_path}/tmp/sockets/puma.sock"
    end
  end

  before :start, :make_dirs
  before :start, :source_env
  after :start, :fix_socket_permissions
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      puts `git rev-parse HEAD`
      #unless `git rev-parse HEAD` == `git rev-parse bitbucket/master`
      #  puts "WARNING: HEAD is not the same as bitbucket/master"
      #  puts "Run `git push` to sync changes."
      #  exit
      #end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end


#
#namespace :deploy do
#  desc 'Restart application'
#  task :restart do
#    on roles(:app), in: :sequence, wait: 5 do
#      # Your restart mechanism here, for example:
#      # execute :touch, release_path.join('tmp/restart.txt')
#    end
#  end
#
#  after :publishing, :restart
#
#  after :restart, :clear_cache do
#    on roles(:web), in: :groups, limit: 3, wait: 10 do
#      # Here we can do anything such as:
#      # within release_path do
#      #   execute :rake, 'cache:clear'
#      # end
#    end
#  #end
#end
