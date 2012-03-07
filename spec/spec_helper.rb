require 'rubygems'
require 'rspec'
require 'amico'
require 'factory_girl'
require 'fakeweb'

ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require "rspec/rails"
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
Rails.backtrace_cleaner.remove_silencers!
FactoryGirl.find_definitions

RSpec.configure do |config|
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