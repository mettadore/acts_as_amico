require 'redis'
require 'amico'
require 'acts_as_amico'
require 'acts_as_amico/version'

module ActsAsAmico
  autoload :AmicoUser,    'acts_as_amico/amico_user'

  require 'acts_as_amico/railtie'
end
