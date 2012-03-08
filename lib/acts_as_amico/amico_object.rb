module ActsAsAmico
  module AmicoObject

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def amico_key
        @amico_key ||= :id
      end

      def acts_as_amico *args
        options = args.extract_options!
        options.assert_valid_keys(:amico_key)
        @amico_key = options[:amico_key]
        include ActsAsAmico::AmicoObject::InstanceMethods
      end
    end

    module InstanceMethods

      def amico_key
        self.send(self.class.amico_key)
      end

      def method_missing(sym, *args, &block)
        if Amico.respond_to? sym
          args[0] = args[0].amico_key if not args[0].nil? and args[0].respond_to?(:amico_key)
          args.unshift(amico_key)
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

      def followers options = {}
        key = options[:scope] || Amico.default_scope_key
        Amico.followers(amico_key, options, key)
      end

      # Named destructive methods
      def follow! obj, *args
        Amico.follow(amico_key, obj.amico_key, *args)
      end
      def unfollow! obj, *args
        Amico.unfollow(amico_key, obj.amico_key, *args)
      end
      def accept! obj, *args
        Amico.accept(amico_key, obj.amico_key, *args)
      end
      def block! obj, *args
        Amico.block(amico_key, obj.amico_key, *args)
      end
      def unblock! obj, *args
        Amico.unblock(amico_key, obj.amico_key, *args)
      end

      private

      def pass_sym_to_amico sym
        Amico.respond_to? sym
      end
    end
  end
end