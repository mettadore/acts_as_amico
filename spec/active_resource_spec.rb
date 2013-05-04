require 'spec_helper'

describe ActsAsAmico do
  before :all do
    FakeWeb.allow_net_connect = false
    @all_resp = '<rest_objects type="array">
                  <rest_object><id>123</id><title>Blah</title><description>Some stuff</description></rest_object>
                  <rest_object><id>321</id><title>Blah</title><description>Some stuff</description></rest_object>
                </rest_objects>'
    @resp_123 = '<rest_object><id>123</id><title>Blah</title><description>Some stuff</description></rest_object>'
    @resp_321 = '<rest_object><id>321</id><title>Blah</title><description>Some stuff</description></rest_object>'

    FakeWeb.register_uri(:get, "http://api.sample.com/rest_objects/123.xml", :body => @resp_123, :status => ["200", "OK"])
    FakeWeb.register_uri(:get, "http://api.sample.com/rest_objects/321.xml", :body => @resp_321, :status => ["200", "OK"])
  end

  after :all do
    FakeWeb.allow_net_connect=true
  end

  before :each do
    @usera = FactoryGirl.create :user
    @admin = FactoryGirl.create :admin
    @rest_object = RestObject.find(321)
  end

  it "Should respond to amico_key on the class" do
    RestObject.respond_to?(:amico_key).should be_true
  end
  it "should set the amico_key on the class" do
    RestObject.amico_key.should be(:title)
  end

  it "should hold an amico_key" do
    @rest_object.amico_key.should eq("Blah")
  end

  it "should follow" do
    @usera.follow! @admin, :scope => 'admin'
    @usera.following?(@admin, :scope => 'admin').should be_true
    @admin.followers(:scope => 'admin').include?(@usera.amico_key.to_s).should be_true
  end
  it "should allow following an ActiveResource object" do
    @usera.follow! @rest_object, :scope => 'rest_object'
    @usera.following?(@rest_object, :scope => 'rest_object').should be_true

    @rest_object.followers(:scope => 'rest_object').include?(@usera.amico_key.to_s).should be_true
  end


end