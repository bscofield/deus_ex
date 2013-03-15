require 'logger'

module DeusEx
  class AWS
    IMAGE_ID        = 'ami-3679e75f'
    DEPLOY_PROJECT  = 'deus_ex_project'
    REMOTE_USER     = 'ubuntu'
    GIT_REMOTE_NAME = 'deus-ex'

    def self.setup
      aws = new
      aws.setup_connection
      aws.setup_server
      aws.setup_repository
      aws.setup_git_remote
    rescue Exception => e
      log "error: #{e.inspect}"
      aws.clean_up
    end

    def self.cleanup
      aws = new
      aws.setup_connection
      aws.clean_up
    end

    def setup_connection
      @connection = Fog::Compute.new({
        :provider => 'AWS'
      })
      log "connection complete"
    end

    def setup_server
      log "creating server"
      @server = @connection.servers.bootstrap({
        :image_id => IMAGE_ID,
        :username => REMOTE_USER
      })
      log "server created"
    end

    def setup_repository
      log "initializing git repo"
      @server.ssh([
        "mkdir #{DEPLOY_PROJECT}.git",
        "cd #{DEPLOY_PROJECT}.git && git init --bare"
      ])

      log "git repo initialized"
      log git_remote
    end

    def setup_git_remote
      if system('git rev-parse')
        log "adding git remote"
        system "git remote add #{GIT_REMOTE_NAME} #{git_remote}"
        system "git config --global remote.#{GIT_REMOTE_NAME}.receivepack \"git receive-pack\""

        log "pushing to remote #{git_remote}"
        system "git push #{GIT_REMOTE_NAME} master"

        log "removing git remote"
        system "git remote rm #{GIT_REMOTE_NAME}"
      else
        warn "not in a git repo"
      end
    end

    def clean_up
      if @server
        @server.destroy
      else
        @connection.servers.select {|s| s.image_id == IMAGE_ID}.map(&:destroy)
      end
      log "server destroyed"
    end

    def git_remote
      "#{REMOTE_USER}@#{@server.dns_name}:#{DEPLOY_PROJECT}.git"
    end

    def log(message, level = :info, logger = Logger.new($stdout))
      logger.send(level, ["[DEUS EX]", message].join(' '))
    end

    def warn(message)
      log message, :warn
    end
  end
end