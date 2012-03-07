require 'acts_as_amico'
require 'rails'

module ActsAsAmico
  class Railtie < Rails::Railtie

    initializer "acts_as_amico.active_record" do |app|
      ActiveSupport.on_load :active_record do
        include ActsAsAmico::AmicoObject
      end
    end

    initializer "acts_as_amico.active_resource" do |app|
      ActiveSupport.on_load :active_resource do
        include ActsAsAmico::AmicoObject
      end
    end

  end
end
