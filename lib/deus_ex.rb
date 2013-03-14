require 'bundler/setup'
require 'fog'
require File.join(File.dirname(__FILE__), 'deus_ex', 'aws')

module DeusEx
  def self.setup
    DeusEx::AWS.setup
  end
end
