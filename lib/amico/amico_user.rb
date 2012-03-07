module Amico
  module AmicoUser

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def amico_key
        @amico_key ||= "id"
      end
      def amico_key= value
        @amico_key = value
      end

      def acts_as_amico *args
        options = args.extract_options!
        options.assert_valid_keys(:amico_key)
        @amico_key = options[:amico_key] ? options[:amico_key] : "id"
        include Amico::AmicoUser::InstanceMethods
      end
    end

    module InstanceMethods

      def method_missing(sym, *args, &block)
        if Amico.respond_to? sym
          args[0] = args[0].send(args[0].class.amico_key) if not args[0].nil? and args[0].respond_to?(:id)
          args.unshift(self.send(self.class.amico_key))
          if sym.nil?
            Amico.send(*args, &block)
          else
            Amico.send(sym, *args, &block)
          end
        else
          super
        end
      end

      def respond_to?(sym)
        pass_sym_to_amico(sym) || super(sym)
      end

      # Named destructive methods
      def follow! obj, *args
        Amico.follow(self.send(self.class.amico_key), obj.send(obj.class.amico_key), *args)
      end
      def unfollow! obj, *args
        Amico.unfollow(self.send(self.class.amico_key), obj.send(obj.class.amico_key), *args)
      end
      def accept! obj, *args
        Amico.accept(self.send(self.class.amico_key), obj.send(obj.class.amico_key), *args)
      end
      def block! obj, *args
        Amico.block(self.send(self.class.amico_key), obj.send(obj.class.amico_key), *args)
      end
      def unblock! obj, *args
        Amico.unblock(self.send(self.class.amico_key), obj.send(obj.class.amico_key), *args)
      end

      private

      def pass_sym_to_amico sym
        Amico.respond_to? sym
      end
    end
  end
end