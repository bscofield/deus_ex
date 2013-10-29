require 'bundler/setup'
require 'fog'
require File.join(File.dirname(__FILE__), 'deus_ex', 'machina')

module DeusEx
  def self.setup
    DeusEx::Machina.setup
  end

  def self.cleanup
    DeusEx::Machina.cleanup
  end

  def self.status
    DeusEx::Machina.status
  end
end
