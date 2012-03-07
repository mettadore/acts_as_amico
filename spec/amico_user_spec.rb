require 'spec_helper'

describe ActsAsAmico do
  before :each do
    @usera = Factory :user
    @userb = Factory :user
    @admin = Factory :admin
    @widget = Factory :widget
    @thing = Factory :thing
  end

  it "should allow both id and non-id keys" do
    @usera.class.amico_key.should eq("id")
    @admin.class.amico_key.should eq("name")
  end

  describe '#follow' do
    it 'should allow you to follow' do
      @usera.follow(@userb)

      Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(1)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(1)
    end

    it 'should not allow you to follow yourself' do
      @usera.follow(@usera)

      Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(0)
    end

    it 'should add each individual to the reciprocated set if you both follow each other' do
      @usera.follow(@userb)
      @userb.follow(@usera)

      Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(1)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(1)
    end
    describe "with non-id key" do
      it 'should allow you to follow' do
        @usera.follow(@admin)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(1)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:#{@admin.send(@admin.class.amico_key)}").should be(1)
      end

      it 'should add each individual to the reciprocated set if you both follow each other' do
        @usera.follow(@admin)
        @admin.follow(@usera)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(1)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@admin.send(@admin.class.amico_key)}").should be(1)
      end

    end
  end

  describe '#unfollow' do
    it 'should allow you to unfollow' do
      @usera.follow(@userb)

      Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(1)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(1)

      @usera.unfollow(@userb)

      Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(0)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(0)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(0)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(0)
    end

    describe "non-id key" do
      it 'should allow you to unfollow' do
        @usera.follow(@admin)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(1)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:#{@admin.send(@admin.class.amico_key)}").should be(1)

        @usera.unfollow(@admin)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:#{@admin.send(@admin.class.amico_key)}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@admin.send(@admin.class.amico_key)}").should be(0)
      end
    end
  end

  describe '#block' do
    it 'should allow you to block someone following you' do
      @userb.follow(@usera)
      @usera.block(@userb)

      Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(0)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(1)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(0)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(0)
    end

    it 'should allow you to block someone who is not following you' do
      @usera.block(@userb)

      Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(0)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(1)
    end

    it 'should not allow someone you have blocked to follow you' do
      @usera.block(@userb)

      Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(0)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(1)

      @userb.follow(@usera)

      Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(0)
      Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(1)
    end

    it 'should not allow you to block yourself' do
      @usera.block(@usera)
      @usera.blocked?(@usera).should be_false
    end
    describe "non-id key" do
      it 'should allow you to block someone following you' do
        @admin.follow(@usera)
        @usera.block(@admin)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@userb.send(@admin.class.amico_key)}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(1)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@userb.send(@admin.class.amico_key)}").should be(0)
      end

      it 'should allow you to block someone who is not following you' do
        @usera.block(@userb)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@userb.send(@admin.class.amico_key)}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(1)
      end

      it 'should not allow someone you have blocked to follow you' do
        @usera.block(@admin)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@userb.send(@admin.class.amico_key)}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(1)

        @admin.follow(@usera)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@userb.send(@admin.class.amico_key)}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(1)
      end

    end
  end

  describe '#unblock' do
    it 'should allow you to unblock someone you have blocked' do
      @usera.block(@userb)
      @usera.blocked?(@userb).should be_true
      @usera.unblock(@userb)
      @usera.blocked?(@userb).should be_false
    end
    it 'should allow you to unblock someone you have blocked with non-id keys' do
      @usera.block(@admin)
      @usera.blocked?(@admin).should be_true
      @usera.unblock(@admin)
      @usera.blocked?(@admin).should be_false
    end
  end

  describe "destructive methods named with ! bang" do
    describe '#follow' do
      it 'should allow you to follow' do
        @usera.follow!(@userb)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(1)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(1)
      end

      it 'should not allow you to follow yourself' do
        @usera.follow!(@usera)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(0)
      end

      it 'should add each individual to the reciprocated set if you both follow each other' do
        @usera.follow!(@userb)
        @userb.follow!(@usera)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(1)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(1)
      end
    end

    describe '#unfollow' do
      it 'should allow you to unfollow' do
        @usera.follow!(@userb)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(1)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(1)

        @usera.unfollow!(@userb)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(0)
      end
    end
    describe '#block!' do
      it 'should allow you to block someone following you' do
        @userb.follow(@usera)
        @usera.block!(@userb)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(1)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.reciprocated_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(0)
      end

      it 'should allow you to block someone who is not following you' do
        @usera.block!(@userb)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(1)
      end

      it 'should not allow someone you have blocked to follow you' do
        @usera.block!(@userb)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(1)

        @userb.follow!(@usera)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.blocked_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(1)
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
    describe "non-id keys" do
      it 'should return that you are following' do
        @usera.follow(@admin)
        @usera.following?(@admin).should be_true
        @admin.following?(@usera).should be_false

        @admin.follow(@usera)
        @admin.following?(@usera).should be_true
      end
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
    describe "non-id keys" do
      it 'should return that you are being followed' do
        @admin.follow(@usera)
        @usera.follower?(@admin).should be_true
        @admin.follower?(@usera).should be_false

        @usera.follow(@admin)
        @admin.follower?(@usera).should be_true
      end
    end
  end

  describe '#blocked?' do
    it 'should return that someone is being blocked' do
      @usera.block(@userb)
      @usera.blocked?(@userb).should be_true
      @userb.following?(@usera).should be_false
    end
    describe "non-id keys" do
      it 'should return that someone is being blocked' do
        @usera.block(@admin)
        @usera.blocked?(@admin).should be_true
        @admin.following?(@usera).should be_false
      end
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
    describe "non-id keys" do
      it 'should return true if both individuals are following each other' do
        @usera.follow(@admin)
        @admin.follow(@usera)
        @usera.reciprocated?(@admin).should be_true
      end

      it 'should return false if both individuals are not following each other' do
        @usera.follow(@admin)
        @usera.reciprocated?(@admin).should be_false
      end
    end
  end

  describe '#following' do
    it 'should return the correct list' do
      userc = Factory :user
      @usera.follow(@userb)
      @usera.follow(userc)
      @usera.following.should eql(["#{userc.id}", "#{@userb.send(@userb.class.amico_key)}"])
      @usera.following(:page => 5).should eql(["#{userc.id}", "#{@userb.send(@userb.class.amico_key)}"])
    end

    it 'should page correctly' do
      user = add_reciprocal_followers

      user.following(:page => 1, :page_size => 5).size.should be(5)
      user.following(:page => 1, :page_size => 10).size.should be(10)
      user.following(:page => 1, :page_size => 25).size.should be(25)
    end
    describe "non-id keys" do
      it 'should return the correct list' do
        userc = Factory :user
        @usera.follow(@admin)
        @usera.follow(userc)
        @usera.following.should =~ ["#{userc.id}", "#{@admin.send(@admin.class.amico_key)}"]
        @usera.following(:page => 5).should =~ ["#{userc.id}", "#{@admin.send(@admin.class.amico_key)}"]
      end
    end
  end

  describe '#followers' do
    it 'should return the correct list' do
      userc = Factory :user
      @usera.follow(@userb)
      userc.follow(@userb)
      @userb.followers.should eql(["#{userc.id}", "#{@usera.send(@usera.class.amico_key)}"])
      @userb.followers(:page => 5).should eql(["#{userc.id}", "#{@usera.send(@usera.class.amico_key)}"])
    end

    it 'should page correctly' do
      user = add_reciprocal_followers

      user.followers(:page => 1, :page_size => 5).size.should be(5)
      user.followers(:page => 1, :page_size => 10).size.should be(10)
      user.followers(:page => 1, :page_size => 25).size.should be(25)
    end
    describe "non-id keys" do
      it 'should return the correct list' do
        userc = Factory :user
        @usera.follow(@admin)
        userc.follow(@admin)
        @admin.followers.should eql(["#{userc.id}", "#{@usera.send(@usera.class.amico_key)}"])
        @admin.followers(:page => 5).should eql(["#{userc.id}", "#{@usera.send(@usera.class.amico_key)}"])
      end
    end
  end

  describe '#blocked' do
    it 'should return the correct list' do
      userc = Factory :user
      @usera.block(@userb)
      @usera.block(userc)
      @usera.blocked.should eql(["#{userc.id}", "#{@userb.send(@userb.class.amico_key)}"])
      @usera.blocked(:page => 5).should eql(["#{userc.id}", "#{@userb.send(@userb.class.amico_key)}"])
    end

    it 'should page correctly' do
      user = add_reciprocal_followers(26, true)

      user.blocked(:page => 1, :page_size => 5).size.should be(5)
      user.blocked(:page => 1, :page_size => 10).size.should be(10)
      user.blocked(:page => 1, :page_size => 25).size.should be(25)
    end
    describe "non-id keys" do
      it 'should return the correct list' do
        userc = Factory :user
        @usera.block(@admin)
        @usera.block(userc)
        @usera.blocked.should =~ ["#{userc.id}", "#{@admin.send(@admin.class.amico_key)}"]
        @usera.blocked(:page => 5).should =~ ["#{userc.id}", "#{@admin.send(@admin.class.amico_key)}"]
      end
    end
  end

  describe '#reciprocated' do
    it 'should return the correct list' do
      @usera.follow(@userb)
      @userb.follow(@usera)
      @usera.reciprocated.should eql(["#{@userb.send(@userb.class.amico_key)}"])
      @userb.reciprocated.should eql(["#{@usera.send(@usera.class.amico_key)}"])
    end

    it 'should page correctly' do
      user = add_reciprocal_followers

      user.reciprocated(:page => 1, :page_size => 5).size.should be(5)
      user.reciprocated(:page => 1, :page_size => 10).size.should be(10)
      user.reciprocated(:page => 1, :page_size => 25).size.should be(25)
    end
    describe "non-id keys" do
      it 'should return the correct list' do
        @usera.follow(@admin)
        @admin.follow(@usera)
        @usera.reciprocated.should eql(["#{@admin.send(@admin.class.amico_key)}"])
        @admin.reciprocated.should eql(["#{@usera.send(@usera.class.amico_key)}"])
      end
    end
  end

  describe '#following_count' do
    it 'should return the correct count' do
      @usera.follow(@userb)
      @usera.following_count.should be(1)
    end
    it 'should return the correct count for non-id keys' do
      @usera.follow(@admin)
      @usera.following_count.should be(1)
    end
  end

  describe '#followers_count' do
    it 'should return the correct count' do
      @usera.follow(@userb)
      @userb.followers_count.should be(1)
    end
    it 'should return the correct count for non-id keys' do
      @usera.follow(@admin)
      @admin.followers_count.should be(1)
    end
  end

  describe '#blocked_count' do
    it 'should return the correct count' do
      @usera.block(@userb)
      @usera.blocked_count.should be(1)
    end
    it 'should return the correct count for non-id keys' do
      @usera.block(@admin)
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
    it 'should return the correct count for non-id keys' do
      userc = Factory :user
      userd = Factory :user
      @usera.follow(@admin)
      @admin.follow(@usera)
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

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.pending_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(1)
      end

      it 'should remove the pending relationship if you have a pending follow, but you unfollow' do
        @usera.follow(@userb)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.pending_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(1)

        @usera.unfollow(@userb)

        Amico.redis.zcard("#{Amico.namespace}:#{Amico.following_key}:#{Amico.default_scope_key}:#{@usera.send(@usera.class.amico_key)}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.followers_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(0)
        Amico.redis.zcard("#{Amico.namespace}:#{Amico.pending_key}:#{Amico.default_scope_key}:#{@userb.send(@userb.class.amico_key)}").should be(0)
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
        @usera.pending.should eql(["#{@userb.send(@userb.class.amico_key)}"])
        @userb.pending.should eql(["#{@usera.send(@usera.class.amico_key)}"])
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
      @usera.following.should eql(["#{@userb.send(@userb.class.amico_key)}"])
      @usera.following( {:page_size => Amico.page_size, :page => 1}, 'user').should eql(["#{@userb.send(@userb.class.amico_key)}"])
      @usera.following?(@userb, 'project').should be_false
      @usera.follow(@userb, 'project')
      @usera.following?(@userb, 'project').should be_true
      @usera.following( {:page_size => Amico.page_size, :page => 1}, 'project').should eql(["#{@userb.send(@userb.class.amico_key)}"])
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