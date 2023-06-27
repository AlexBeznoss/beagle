# commands used to deploy a Rails application
namespace :fly do
  task :console do # rubocop:disable Rails/RakeEnvironment
    sh 'fly ssh console -r sea -C "/app/bin/rails console"'
  end

  # BUILD step:
  #  - changes to the filesystem made here DO get deployed
  #  - NO access to secrets, volumes, databases
  #  - Failures here prevent deployment
  task build: "assets:precompile"

  # RELEASE step:
  #  - changes to the filesystem made here are DISCARDED
  #  - full access to secrets, databases
  #  - failures here prevent deployment
  task release: "db:migrate"

  # SERVER step:
  #  - changes to the filesystem made here are deployed
  #  - full access to secrets, databases
  #  - failures here result in VM being stated, shutdown, and rolled back
  #    to last successful deploy (if any).
  task :run, [:cmd] => :swapfile do |_, args|
    case args[:cmd]
    when "server"
      sh "bin/rails server"
    else
      sh "bundle exec #{args[:cmd]}"
    end
  end

  # Send a release notification to honeybadger
  task :hbrelease do # rubocop:disable Rails/RakeEnvironment
    env = "production"
    revision = `git rev-parse HEAD`.strip
    username = `whoami`.strip
    repo = "git@github.com:AlexBeznoss/beagle.git"

    sh "bundle exec honeybadger deploy -r #{repo} -s #{revision} -u #{username} -e #{env}"
  end

  # optional SWAPFILE task:
  #  - adjust fallocate size as needed
  #  - performance critical applications should scale memory to the
  #    point where swap is rarely used.  'fly scale help' for details.
  #  - disable by removing dependency on the :server task, thus:
  #        task :server do
  task :swapfile do # rubocop:disable Rails/RakeEnvironment
    sh "fallocate -l 512M /swapfile"
    sh "chmod 0600 /swapfile"
    sh "mkswap /swapfile"
    sh "echo 10 > /proc/sys/vm/swappiness"
    sh "swapon /swapfile"
  end
end
