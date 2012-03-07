require 'rspec'
require 'amico'
require 'factory_girl'
require 'fakeweb'
require "rspec/rails"

ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  FactoryGirl.find_definitions
  require 'rspec/expectations'
  config.include RSpec::Matchers
  config.color_enabled = true

  # == Mock Framework
  config.mock_with :rspec
  config.before(:all) do
    Amico.configure do |configuration|
      redis = Redis.new(:db => 15)
      configuration.redis = redis
    end
  end

  config.before(:each) do
    Amico.redis.flushdb
  end

  config.after(:all) do
  	Amico.redis.flushdb
    Amico.redis.quit
  end
end