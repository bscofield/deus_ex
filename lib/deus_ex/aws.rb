module DeusEx
  class AWS
    DEPLOY_PROJECT = 'deus_ex_project'
    REMOTE_USER    = 'deus_ex'

    def self.setup
      aws = new
      aws.setup_connection
      aws.setup_server
      aws.setup_repository
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
        :image_id => 'ami-3679e75f',
        :username => REMOTE_USER
      })
      @server.wait_for { ready? }
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
      @server.destroy
      log "server destroyed"
    end

    def git_remote
      "git remote add deus-ex #{REMOTE_USER}@#{@server.dns_name}:#{DEPLOY_PROJECT}.git"
    end

    def log(message)
      puts ["[DEUS EX]", message].join ' '
    end
  end
end