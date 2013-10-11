require 'logger'
require 'yaml'

module DeusEx
  class Machina
    NAME            = 'deus_ex'
    DEPLOY_PROJECT  = 'deus_ex_project'
    GIT_REMOTE_NAME = 'deus-ex'

    def self.setup
      machina = new
      machina.config_read
      machina.setup_server
      machina.setup_repository
      machina.setup_git_remote
    rescue Exception => e
      if e.is_a?(SystemExit)
        machina.log "Exiting"
      else
        machina.log "error: #{e.inspect}"
        machina.clean_up
        raise e
      end
    end

    def self.cleanup
      machina = new
      machina.config_read
      machina.clean_up
    rescue Exception => e
      if e.is_a?(SystemExit)
        machina.log "Exiting"
      else
        machina.log "error: #{e.inspect}"
        machina.clean_up
        raise e
      end
    end

    def self.status
      machina = new
      machina.config_read
      machina.status
    rescue Exception => e
      if e.is_a?(SystemExit)
        machina.log "Exiting"
      else
        machina.log "error: #{e.inspect}"
        machina.clean_up
        raise e
      end
    end

    def compute
      connection = ::Fog::Compute.new(@config[:authentication].dup)
      log "connection established"
      connection
    end

    def network
      authentication = @config[:authentication].dup
      authentication.delete(:version)
      ::Fog::Network.new(authentication)
    end

    def config_read
      @config = YAML.load_file('.machina.yml') if @config.nil?
    end

    def setup_server
      log "creating server (this may take a couple of minutes)"
      server_config = @config[:server_create].dup
      server_config[:name] = NAME
      @server = compute.servers.create(server_config)
      log "server created"
      @server.wait_for { print '.'; ready? }
      log "server ready"
      if @config[:floating_ip_create].nil?
        @ip = @server.public_ip_address
      else
        create_floating_ip
      end
    end

    def create_floating_ip
      floater = network.floating_ips.create(@config[:floating_ip_create])
      floating_id = floater.id
      @ip = floater.floating_ip_address
      @port = 22
      port = network.ports(:filters => { :device_id => @server.id }).first
      network.associate_floating_ip(floating_id, port.id)
    end

    def test_ssh
      socket = TCPSocket.new(@ip, @port)
      IO.select([socket], nil, nil, 5)
    rescue SocketError, Errno::ECONNREFUSED,
      Errno::EHOSTUNREACH, Errno::ENETUNREACH, IOError
      sleep 2
      false
    rescue Errno::EPERM, Errno::ETIMEDOUT
      false
    ensure
      socket && socket.close
    end

    def setup_repository
      log "initializing git repo"
      @server.private_key_path = @config[:private_key_path]
      ssh_options = {
        :port => @port,
        :key_data => [File.read(@config[:private_key_path])],
        :auth_methods => ["publickey"]
      }
      log "." until test_ssh
      Fog::SSH.new(@ip, @config[:username], ssh_options).run([
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
        system "ssh-agent bash -c 'ssh-add #{@config[:private_key_path]}; git push #{GIT_REMOTE_NAME} master'"

        log "removing local git remote"
        system "git remote rm #{GIT_REMOTE_NAME}"

        log ""
        log "you can now deploy from #{git_remote}"
      else
        warn "not in a git repo"
      end
    end

    def clean_up
      destroyed = servers.map(&:destroy).count
      log "#{destroyed} server#{'s' if destroyed != 1} destroyed"
    end

    def status
      log "#{servers.count} server#{'s' if servers.count != 1} found"
    end

    def servers
      @server ? [@server] : compute.servers.select { |s| s.name == NAME }
    end

    def git_remote
      "#{@config[:username]}@#{@server.public_ip_address}:#{DEPLOY_PROJECT}.git"
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
