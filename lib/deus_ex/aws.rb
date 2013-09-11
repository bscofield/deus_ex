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
      if e.is_a?(SystemExit)
        aws.log "Exiting"
      else
        aws.log "error: #{e.inspect}"
        aws.clean_up
        raise e
      end
    end

    def self.cleanup
      aws = new
      aws.setup_connection
      aws.clean_up
    rescue Exception => e
      if e.is_a?(SystemExit)
        aws.log "Exiting"
      else
        aws.log "error: #{e.inspect}"
        aws.clean_up
        raise e
      end
    end

    def setup_connection
      check_for_credentials

      @connection = Fog::Compute.new({
        :provider => 'AWS'
      })
      log "connection established"
    end

    def check_for_credentials
      required_keys = %i(aws_access_key_id aws_secret_access_key private_key_path public_key_path)
      if required_keys.any? { |key| Fog.credentials[key].nil? }
        log "Please ensure that your AWS credentials are stored in ~/.fog; see the README for more information.", :fatal
        abort
      end
    end

    def setup_server
      log "creating server (this may take a couple of minutes)"
      @server = @connection.servers.bootstrap({
        :image_id  => IMAGE_ID,
        :username  => REMOTE_USER
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
    end

    def setup_git_remote
      if system('git rev-parse')
        log "adding local git remote"
        system "git remote add #{GIT_REMOTE_NAME} #{git_remote}"

        log "pushing to remote"
        system "ssh-agent bash -c 'ssh-add #{ssh_key}; git push #{GIT_REMOTE_NAME} master'"

        log "removing local git remote"
        system "git remote rm #{GIT_REMOTE_NAME}"

        log ""
        log "you can now deploy from #{git_remote}"
      else
        warn "not in a git repo"
      end
    end

    def clean_up
      servers = @server ? [@server] : @connection.servers.select { |s| s.image_id == IMAGE_ID }
      destroyed = servers.map(&:destroy).count
      log "#{destroyed} server#{'s' if destroyed != 1} destroyed"
    end

    def ssh_key
      Fog.credentials[:private_key_path]
    end

    def git_remote
      "#{REMOTE_USER}@#{@server.dns_name}:#{DEPLOY_PROJECT}.git"
    end

    def log(message, level = :info, logger = Logger.new($stdout))
      logger.formatter = proc do |severity, datetime, progname, msg|
        "[DEUS EX] #{msg}\n"
      end

      logger.send(level, message)
    end

    def warn(message)
      log message, :warn
    end
  end
end