require 'bundler/setup'
require 'fog'
require File.join(File.dirname(__FILE__), 'deus_ex', 'aws')

module DeusEx
  def self.setup
    DeusEx::AWS.setup
  end

  def self.cleanup
    DeusEx::AWS.cleanup
  end

  def self.status
    DeusEx::AWS.status
  end
end
