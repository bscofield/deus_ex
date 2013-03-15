module DeusEx
  class AWS
    IMAGE_ID       = 'ami-3679e75f'
    DEPLOY_PROJECT = 'deus_ex_project'
    REMOTE_USER    = 'ubuntu'

    def self.setup
      aws = new
      aws.setup_connection
      aws.setup_server
      aws.setup_repository
      aws.clean_up
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
        "cd #{DEPLOY_PROJECT}.git",
        'git init --bare'
      ])

      log "git repo initialized"
      log git_remote
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
      "git remote add deus-ex #{REMOTE_USER}@#{@server.dns_name}:#{DEPLOY_PROJECT}.git"
    end

    def log(message, logger = $stdout)
      logger.puts ["[DEUS EX]", message].join ' '
    end
  end
end