module Amico
  module AmicoUser

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def is_amico
        include Amico::AmicoUser::InstanceMethods
      end
    end

    module InstanceMethods

      def method_missing(sym, *args, &block)
        args.push(self.id)
        Amico.call(sym, *args, &block)
      end

      def respond_to?(sym)
        pass_sym_to_amico?(sym) || super(sym)
      end

      private

      def pass_sym_to_amico sym
        Amico.respond_to? sym
      end
    end
  end
end