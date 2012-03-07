require 'redis'
require 'amico/version'
require 'amico/configuration'
require 'amico/relationships'

module Amico
  autoload :AmicoUser,    'amico/amico_user'
  extend Configuration
  extend Relationships

  require 'amico/railtie' if defined?(Rails) && Rails::Version::Major >= 3
end

ActiveRecord::Base.send :include, Amico::AmicoUser
ActiveResource::Base.send :include, Amico::AmicoUser
