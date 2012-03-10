require 'rails/all'
require 'redis'
require 'amico'
require 'acts_as_amico'
require 'acts_as_amico/version'

module ActsAsAmico
  autoload :AmicoObject,    'acts_as_amico/amico_object'
end

ActiveRecord::Base.send :include, ActsAsAmico::AmicoObject
ActiveResource::Base.send :include, ActsAsAmico::AmicoObject
