require 'spec_helper'

describe Amico::Relationships do
  describe "is_amico style" do
    before :each do
      @usera = Factory :user
      @userb = Factory :user
      @admin = Factory :admin
      @widget = Factory :widget
      @thing = Factory :thing
    end

    describe '#follow' do
      it 'should allow you to follow' do
        @usera.follow(@userb)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(1)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(1)
      end

      it 'should not allow you to follow yourself' do
        @usera.follow(@usera)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(0)
      end

      it 'should add each individual to the reciprocated set if you both follow each other' do
        @usera.follow(@userb)
        @userb.follow(@usera)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(1)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(1)
      end
    end

    describe '#unfollow' do
      it 'should allow you to unfollow' do
        @usera.follow(@userb)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(1)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(1)

        @usera.unfollow(@userb)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(0)
      end
    end

    describe '#block' do
      it 'should allow you to block someone following you' do
        @userb.follow(@usera)
        @usera.block(@userb)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(1)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(0)
      end

      it 'should allow you to block someone who is not following you' do
        @usera.block(@userb)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(1)
      end

      it 'should not allow someone you have blocked to follow you' do
        @usera.block(@userb)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(1)

        @userb.follow(@usera)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(1)
      end

      it 'should not allow you to block yourself' do
        @usera.block(@usera)
        @usera.blocked?(@usera).should be_false
      end
    end

    describe '#unblock' do
      it 'should allow you to unblock someone you have blocked' do
        @usera.block(@userb)
        @usera.blocked?(@userb).should be_true
        @usera.unblock(@userb)
        @usera.blocked?(@userb).should be_false
      end
    end

    describe "destructive methods named with ! bang" do
      describe '#follow' do
        it 'should allow you to follow' do
          @usera.follow!(@userb)

          Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(1)
          Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(1)
        end

        it 'should not allow you to follow yourself' do
          @usera.follow!(@usera)

          Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(0)
        end

        it 'should add each individual to the reciprocated set if you both follow each other' do
          @usera.follow!(@userb)
          @userb.follow!(@usera)

          Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(1)
          Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(1)
        end
      end

      describe '#unfollow' do
        it 'should allow you to unfollow' do
          @usera.follow!(@userb)

          Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(1)
          Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(1)

          @usera.unfollow!(@userb)

          Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(0)
          Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(0)
          Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(0)
          Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(0)
        end
      end
      describe '#block!' do
        it 'should allow you to block someone following you' do
          @userb.follow(@usera)
          @usera.block!(@userb)

          Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(0)
          Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(1)
          Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(0)
          Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(0)
        end

        it 'should allow you to block someone who is not following you' do
          @usera.block!(@userb)

          Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(0)
          Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(1)
        end

        it 'should not allow someone you have blocked to follow you' do
          @usera.block!(@userb)

          Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(0)
          Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(1)

          @userb.follow!(@usera)

          Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(0)
          Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(1)
        end

        it 'should not allow you to block yourself' do
          @usera.block!(@usera)
          @usera.blocked?(@usera).should be_false
        end
      end
      describe '#unblock!' do
        it 'should allow you to unblock someone you have blocked' do
          @usera.block!(@userb)
          @usera.blocked?(@userb).should be_true
          @usera.unblock!(@userb)
          @usera.blocked?(@userb).should be_false
        end
      end

    end

    describe '#following?' do
      it 'should return that you are following' do
        @usera.follow(@userb)
        @usera.following?(@userb).should be_true
        @userb.following?(@usera).should be_false

        @userb.follow(@usera)
        @userb.following?(@usera).should be_true
      end
    end

    describe '#follower?' do
      it 'should return that you are being followed' do
        @userb.follow(@usera)
        @usera.follower?(@userb).should be_true
        @userb.follower?(@usera).should be_false

        @usera.follow(@userb)
        @userb.follower?(@usera).should be_true
      end
    end

    describe '#blocked?' do
      it 'should return that someone is being blocked' do
        @usera.block(@userb)
        @usera.blocked?(@userb).should be_true
        @userb.following?(@usera).should be_false
      end
    end

    describe '#reciprocated?' do
      it 'should return true if both individuals are following each other' do
        @usera.follow(@userb)
        @userb.follow(@usera)
        @usera.reciprocated?(@userb).should be_true
      end

      it 'should return false if both individuals are not following each other' do
        @usera.follow(@userb)
        @usera.reciprocated?(@userb).should be_false
      end
    end

    describe '#following' do
      it 'should return the correct list' do
        userc = Factory :user
        @usera.follow(@userb)
        @usera.follow(userc)
        @usera.following.should eql(["#{userc.id}", "#{@userb.id}"])
        @usera.following(:page => 5).should eql(["#{userc.id}", "#{@userb.id}"])
      end

      it 'should page correctly' do
        user = add_reciprocal_followers

        user.following(:page => 1, :page_size => 5).size.should be(5)
        user.following(:page => 1, :page_size => 10).size.should be(10)
        user.following(:page => 1, :page_size => 25).size.should be(25)
      end
    end

    describe '#followers' do
      it 'should return the correct list' do
        userc = Factory :user
        @usera.follow(@userb)
        userc.follow(@userb)
        @userb.followers.should eql(["#{userc.id}", "#{@usera.id}"])
        @userb.followers(:page => 5).should eql(["#{userc.id}", "#{@usera.id}"])
      end

      it 'should page correctly' do
        user = add_reciprocal_followers

        user.followers(:page => 1, :page_size => 5).size.should be(5)
        user.followers(:page => 1, :page_size => 10).size.should be(10)
        user.followers(:page => 1, :page_size => 25).size.should be(25)
      end
    end

    describe '#blocked' do
      it 'should return the correct list' do
        userc = Factory :user
        @usera.block(@userb)
        @usera.block(userc)
        @usera.blocked.should eql(["#{userc.id}", "#{@userb.id}"])
        @usera.blocked(:page => 5).should eql(["#{userc.id}", "#{@userb.id}"])
      end

      it 'should page correctly' do
        user = add_reciprocal_followers(26, true)

        user.blocked(:page => 1, :page_size => 5).size.should be(5)
        user.blocked(:page => 1, :page_size => 10).size.should be(10)
        user.blocked(:page => 1, :page_size => 25).size.should be(25)
      end
    end

    describe '#reciprocated' do
      it 'should return the correct list' do
        @usera.follow(@userb)
        @userb.follow(@usera)
        @usera.reciprocated.should eql(["#{@userb.id}"])
        @userb.reciprocated.should eql(["#{@usera.id}"])
      end

      it 'should page correctly' do
        user = add_reciprocal_followers

        user.reciprocated(:page => 1, :page_size => 5).size.should be(5)
        user.reciprocated(:page => 1, :page_size => 10).size.should be(10)
        user.reciprocated(:page => 1, :page_size => 25).size.should be(25)
      end
    end

    describe '#following_count' do
      it 'should return the correct count' do
        @usera.follow(@userb)
        @usera.following_count.should be(1)
      end
    end

    describe '#followers_count' do
      it 'should return the correct count' do
        @usera.follow(@userb)
        @userb.followers_count.should be(1)
      end
    end

    describe '#blocked_count' do
      it 'should return the correct count' do
        @usera.block(@userb)
        @usera.blocked_count.should be(1)
      end
    end

    describe '#reciprocated_count' do
      it 'should return the correct count' do
        userc = Factory :user
        userd = Factory :user
        @usera.follow(@userb)
        @userb.follow(@usera)
        @usera.follow(userc)
        userc.follow(@usera)
        @usera.follow(userd)
        @usera.reciprocated_count.should be(2)
      end
    end

    describe 'pending_follow enabled' do
      before(:each) do
        Amico.pending_follow = true
      end

      after(:each) do
        Amico.pending_follow = false
      end

      describe '#follow' do
        it 'should allow you to follow but the relationship is initially pending' do
          @usera.follow(@userb)

          Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(0)
          Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(0)
          Amico.redis.zcard("#{Amico.namespace}:#{Amico.pending_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(1)
        end

        it 'should remove the pending relationship if you have a pending follow, but you unfollow' do
          @usera.follow(@userb)

          Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(0)
          Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(0)
          Amico.redis.zcard("#{Amico.namespace}:#{Amico.pending_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(1)

          @usera.unfollow(@userb)

          Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.id}").should be(0)
          Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(0)
          Amico.redis.zcard("#{Amico.namespace}:#{Amico.pending_key}:#{Amico.default_scope_key}:#{@userb.id}").should be(0)
        end

        describe 'removing the pending relationship and add to following and followers if #accept is called' do
          it "should work with non-bang-named methods" do
            @usera.follow(@userb)
            @usera.pending?(@userb).should be_true

            @usera.accept(@userb)

            @usera.pending?(@userb).should be_false
            @usera.following?(@userb).should be_true
            @userb.following?(@usera).should be_false
            @userb.follower?(@usera).should be_true
            @usera.follower?(@userb).should be_false
          end
          it "should work with ! bang-named methods" do
            @usera.follow!(@userb)
            @usera.pending?(@userb).should be_true

            @usera.accept!(@userb)

            @usera.pending?(@userb).should be_false
            @usera.following?(@userb).should be_true
            @userb.following?(@usera).should be_false
            @userb.follower?(@usera).should be_true
            @usera.follower?(@userb).should be_false
          end
        end

        describe 'removing the pending relationship and add to following and followers if #accept is called and add to reciprocated relationship' do
          it "should work with non-bang-named methods" do
            @usera.follow(@userb)
            @userb.follow(@usera)
            @usera.pending?(@userb).should be_true
            @userb.pending?(@usera).should be_true

            @usera.accept(@userb)

            @usera.pending?(@userb).should be_false
            @userb.pending?(@usera).should be_true
            @usera.following?(@userb).should be_true
            @userb.following?(@usera).should be_false
            @userb.follower?(@usera).should be_true
            @usera.follower?(@userb).should be_false

            @userb.accept(@usera)

            @usera.pending?(@userb).should be_false
            @userb.pending?(@usera).should be_false
            @usera.following?(@userb).should be_true
            @userb.following?(@usera).should be_true
            @userb.follower?(@usera).should be_true
            @usera.follower?(@userb).should be_true
            @usera.reciprocated?(@userb).should be_true
          end
          it "should work with ! bang-named methods" do
            @usera.follow!(@userb)
            @userb.follow!(@usera)
            @usera.pending?(@userb).should be_true
            @userb.pending?(@usera).should be_true

            @usera.accept!(@userb)

            @usera.pending?(@userb).should be_false
            @userb.pending?(@usera).should be_true
            @usera.following?(@userb).should be_true
            @userb.following?(@usera).should be_false
            @userb.follower?(@usera).should be_true
            @usera.follower?(@userb).should be_false

            @userb.accept!(@usera)

            @usera.pending?(@userb).should be_false
            @userb.pending?(@usera).should be_false
            @usera.following?(@userb).should be_true
            @userb.following?(@usera).should be_true
            @userb.follower?(@usera).should be_true
            @usera.follower?(@userb).should be_true
            @usera.reciprocated?(@userb).should be_true
          end
        end
      end

      describe '#block' do
        it 'should remove the pending relationship if you block someone' do
          @userb.follow(@usera)
          @userb.pending?(@usera).should be_true
          @usera.block(@userb)
          @userb.pending?(@usera).should be_false
          @usera.blocked?(@userb).should be_true
        end
      end

      describe '#pending' do
        it 'should return the correct list' do
          @usera.follow(@userb)
          @userb.follow(@usera)
          @usera.pending.should eql(["#{@userb.id}"])
          @userb.pending.should eql(["#{@usera.id}"])
        end

        it 'should page correctly' do
          user = add_reciprocal_followers

          user.pending(:page => 1, :page_size => 5).size.should be(5)
          user.pending(:page => 1, :page_size => 10).size.should be(10)
          user.pending(:page => 1, :page_size => 25).size.should be(25)
        end
      end

      describe '#pending_count' do
        it 'should return the correct count' do
          userc = Factory :user
          userd = Factory :user
          @usera.follow(@userb)
          @userb.follow(@usera)
          @usera.follow(userc)
          userc.follow(@usera)
          @usera.follow(userd)
          @usera.pending_count.should be(2)
        end
      end

      describe '#pending_page_count' do
        it 'should return the correct count' do
          user = add_reciprocal_followers

          user.pending_page_count.should be(2)
          user.pending_page_count( 10).should be(3)
          user.pending_page_count( 5).should be(6)
          user.pending_page_count(2).should be(13)
        end
      end
    end

    describe 'scope' do
      it 'should allow you to scope a call to follow a different thing' do
        Amico.default_scope_key = 'user'
        @usera.follow(@userb, 'user')
        @usera.following?(@userb).should be_true
        @usera.following?(@userb, 'user').should be_true
        @usera.following.should eql(["#{@userb.id}"])
        @usera.following( {:page_size => Amico.page_size, :page => 1}, 'user').should eql(["#{@userb.id}"])
        @usera.following?(@userb, 'project').should be_false
        @usera.follow(@userb, 'project')
        @usera.following?(@userb, 'project').should be_true
        @usera.following( {:page_size => Amico.page_size, :page => 1}, 'project').should eql(["#{@userb.id}"])
      end
    end

    private

    def add_reciprocal_followers(count = 26, block_relationship = false)
      outer_user = nil
      1.upto(count) do
        outer_user = Factory :user
        1.upto(count) do
          inner_user = Factory :user
          outer_user.follow! inner_user
          inner_user.follow! outer_user
          if block_relationship
            outer_user.block! inner_user
            inner_user.block! outer_user
          end
        end
      end
      outer_user
    end
  end
end