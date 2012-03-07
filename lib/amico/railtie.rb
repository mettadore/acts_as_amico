require 'amico'
require 'rails'

module Amico
  class Railtie < Rails::Railtie

    initializer "amico.active_record" do |app|
      ActiveSupport.on_load :active_record do
        include Amico::AmicoUser
      end
    end

    initializer "amico.active_resource" do |app|
      ActiveSupport.on_load :active_resource do
        include Amico::AmicoUser
      end
    end

  end
end
