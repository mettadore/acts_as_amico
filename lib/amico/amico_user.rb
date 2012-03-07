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

      def follow obj, scope = Amico.default_scope_key
        Amico.follow(self.id, obj.id, scope)
      end

      def following? obj, scope = Amico.default_scope_key
        Amico.following?(self.id, obj.id, scope)
      end

      def following scope = Amico.default_scope_key
        Amico.following(self.id, scope)
      end

      def following_count scope = Amico.default_scope_key
        Amico.following_count(self.id)
      end

      def pending? obj, scope = Amico.default_scope_key
        Amico.pending(self.id, obj.id, scope)
      end

      def accept obj, scope = Amico.default_scope_key
        Amico.accept(self.id, obj.id, scope)
      end

      def follower? obj, scope = Amico.default_scope_key
        Amico.follower?(obj.id, self.id, scope)
      end

      def followers_count
        Amico.followers_count(self.id)
      end

      def reciprocated? obj, scope = Amico.default_scope_key
        Amico.reciprocated?(self.id, obj.id, scope)
      end

      def reciprocated scope = Amico.default_scope_key
        Amico.reciprocated(self.id, scope)
      end

      def reciprocated_count
        Amico.reciprocated_count(self.id)
      end

      def unfollow obj, scope = Amico.default_scope_key
        Amico.unfollow(self.id, obj.id, scope)
      end

      def block obj, scope = Amico.default_scope_key
        Amico.block(self.id, obj.id, scope)
      end

      def unblock obj, scope = Amico.default_scope_key
        Amico.unblock(self.id, obj.id, scope)
      end

      def blocked? obj, scope = Amico.default_scope_key
        Amico.blocked?(self.id, obj.id, scope)
      end

      def blocked scope = Amico.default_scope_key
        Amico.blocked(self.id, scope)
      end
    end
  end
end