# commands used to deploy a Rails application
namespace :fly do
  task :console do # rubocop:disable Rails/RakeEnvironment
    sh 'fly ssh console -C "/app/bin/rails console"'
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
