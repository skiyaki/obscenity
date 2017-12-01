require 'obscenity/error'
require 'obscenity/config'
require 'obscenity/base'
require 'obscenity/version'

if defined?(::RSpec)
  require 'obscenity/rspec_matcher'
end

module Obscenity extend self
  
  attr_accessor :config
  
  def configure(&block)
    @config = Config.new(&block)
  end
  
  def config
    @config ||= Config.new
  end
  
  def profane?(word, site_code = nil)
    Obscenity::Base.profane?(word, site_code)
  end
  
  def sanitize(text, site_code = nil)
    Obscenity::Base.sanitize(text, site_code)
  end
  
  def replacement(chars)
    Obscenity::Base.replacement(chars)
  end

  def offensive(text, site_code = nil)
    Obscenity::Base.offensive(text, site_code)
  end
  
  
end
  
