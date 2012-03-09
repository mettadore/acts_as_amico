require 'spec_helper'

describe ActsAsAmico do

  describe "non-pending" do
    before :each do
      @user = add_reciprocal_followers
    end

    it 'should page #following correctly' do
      @user.following(:page => 1, :page_size => 5).size.should be(5)
    end

    it 'should page #following correctly' do
      @user.followers(:page => 1, :page_size => 5).size.should be(5)
    end
    it 'should page #reciprocated correctly' do
      @user.reciprocated(:page => 1, :page_size => 5).size.should be(5)
    end
    it "should return all following" do
      @user.get_all(:following).size.should be(6)
    end
  end

  describe "pending operations" do
    before :each do
      Amico.pending_follow = true
      @user = add_reciprocal_followers
    end
    after :all do
      Amico.pending_follow = false
    end

    it 'should page correctly' do
      @user.pending(:page => 1, :page_size => 5).size.should be(5)
    end
    it 'should return the correct count' do
      @user.pending_page_count.should be(1)
      @user.pending_page_count(2).should be(3)
    end
  end

  describe "pending operations" do
    before :each do
      @user = add_reciprocal_followers 6, true
      Amico.pending_follow = true
    end
    after :all do
      Amico.pending_follow = false
    end
    it 'should page #blocked correctly' do
      @user.blocked(:page => 1, :page_size => 5).size.should be(5)
    end
  end

  private

  def add_reciprocal_followers(count = 6, block_relationship = false)
    user = Factory :user
    1.upto(count) do
      inner_user = Factory :user
      user.follow! inner_user
      inner_user.follow! user
      if block_relationship
        user.block! inner_user
        inner_user.block! user
      end
    end
    user
  end

end