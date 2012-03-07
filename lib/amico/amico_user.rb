module Amico
  module AmicoUser

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def key
        @key ||= "id"
      end
      def key= value
        @key = value
      end

      def is_amico *args
        options = args.extract_options!
        options.assert_valid_keys(:key)
        @key = options[:key] ? options[:key] : "id"
        include Amico::AmicoUser::InstanceMethods
      end
    end

    module InstanceMethods

      def method_missing(sym, *args, &block)
        if Amico.respond_to? sym
          args[0] = args[0].send(self.class.key) if not args[0].nil? and args[0].respond_to?(:id)
          args.unshift(self.send(self.class.key))
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
        Amico.follow(self.send(self.class.key), obj.send(self.class.key), *args)
      end
      def unfollow! obj, *args
        Amico.unfollow(self.send(self.class.key), obj.send(self.class.key), *args)
      end
      def accept! obj, *args
        Amico.accept(self.send(self.class.key), obj.send(self.class.key), *args)
      end
      def block! obj, *args
        Amico.block(self.send(self.class.key), obj.send(self.class.key), *args)
      end
      def unblock! obj, *args
        Amico.unblock(self.send(self.class.key), obj.send(self.class.key), *args)
      end

      private

      def pass_sym_to_amico sym
        Amico.respond_to? sym
      end
    end
  end
end