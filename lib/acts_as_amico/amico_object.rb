module ActsAsAmico
  module AmicoObject

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def amico_key
        @amico_key ||= :id
      end

      def amico_methods
        @result || begin
          result = []
          methods = [:following, :followers, :blocked, :reciprocated, :pending]
          methods.each do |m|
            ["_count", "_page_count" ].each do |s|
              result << "#{m.to_s}#{s}".to_sym
            end
          end
          result
        end
      end

      def acts_as_amico *args
        options = args.extract_options!
        options.assert_valid_keys(:amico_key)
        @amico_key = options[:amico_key]
        send :include, ActsAsAmico::AmicoObject::InstanceMethods
      end
    end

    module InstanceMethods

      def amico_key
        self.send(self.class.amico_key)
      end

      def method_missing(sym, *args, &block)
        if self.class.amico_methods.include? sym
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

      def get_all *args
        options = args.extract_options!
        options.assert_valid_keys(:scope)
        valid_params = [:following, :followers, :blocked, :reciprocated, :pending]
        scope = options[:scope] || Amico.default_scope_key
        meth = args[0]
        raise "Must be one of #{valid_params.to_s}" if not valid_params.include? meth
        count = self.send("#{meth.to_s}_count".to_sym, scope)
        count > 0 ? self.send("#{meth}", :page_size => count, :scope => scope) : []
      end

      # Lists
      def followers options = {}
        scope = options[:scope] || Amico.default_scope_key
        Amico.followers amico_key, options, scope
      end
      def following options = {}
        scope = options[:scope] || Amico.default_scope_key
        Amico.following amico_key, options, scope
      end
      def reciprocated options = {}
        scope = options[:scope] || Amico.default_scope_key
        Amico.reciprocated amico_key, options, scope
      end
      def pending options = {}
        scope = options[:scope] || Amico.default_scope_key
        Amico.pending amico_key, options, scope
      end
      def blocked options = {}
        scope = options[:scope] || Amico.default_scope_key
        Amico.blocked amico_key, options, scope
      end

      # Named destructive methods
      def follow! obj, options = {}
        scope = options[:scope] || Amico.default_scope_key
        Amico.follow(amico_key, obj.amico_key, scope)
      end
      def unfollow! obj, options = {}
        scope = options[:scope] || Amico.default_scope_key
        puts amico_key
        puts obj.amico_key
        puts scope
        Amico.unfollow(amico_key, obj.amico_key, scope)
      end
      def accept! obj, options = {}
        scope = options[:scope] || Amico.default_scope_key
        Amico.accept(amico_key, obj.amico_key, scope)
      end
      def block! obj, options = {}
        scope = options[:scope] || Amico.default_scope_key
        Amico.block(amico_key, obj.amico_key, scope)
      end
      def unblock! obj, options = {}
        scope = options[:scope] || Amico.default_scope_key
        Amico.unblock(amico_key, obj.amico_key, scope)
      end

      # Booleans
      def following? obj, options = {}
        scope = options[:scope] || Amico.default_scope_key
        Amico.following?(amico_key, obj.amico_key, scope)
      end
      def follower? obj, options = {}
        scope = options[:scope] || Amico.default_scope_key
        Amico.follower?(amico_key, obj.amico_key, scope)
      end
      def blocked? obj, options = {}
        scope = options[:scope] || Amico.default_scope_key
        Amico.blocked?(amico_key, obj.amico_key, scope)
      end
      def pending? obj, options = {}
        scope = options[:scope] || Amico.default_scope_key
        Amico.pending?(amico_key, obj.amico_key, scope)
      end
      def reciprocated? obj, options = {}
        scope = options[:scope] || Amico.default_scope_key
        Amico.reciprocated?(amico_key, obj.amico_key, scope)
      end

      private

      def pass_sym_to_amico sym
        Amico.respond_to? sym
      end
    end
  end
end