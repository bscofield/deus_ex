require "deus_ex/version"
require 'bundler/setup'
require 'fog'

module DeusEx
  def self.setup_connection
    connection = Fog::Compute.new({
      :provider => 'AWS'
    })
    puts "[DEUS EX] AWS connection complete"
    connection
  end

  def self.setup_server(connection = nil)
    connection ||= setup_connection
    puts "[DEUS EX] creating server..."
    server = connection.servers.bootstrap({
      :image_id => 'ami-3679e75f',
      :username => 'ubuntu'
    })
    puts "[DEUS EX] server created"
    server
  end

  def self.setup_repository(server)
    puts "[DEUS EX] initializing git repo"
    server.ssh([
      'mkdir deploy_project.git',
      'cd deploy_project.git',
      'git init --bare'
    ])

    puts "[DEUS EX] git repo initialized"
    puts "git remote add deus-ex ubuntu@#{s.dns_name}:deploy_project.git"
  end

  def self.setup
    server = setup_server
    setup_repository(server)
  end
end
