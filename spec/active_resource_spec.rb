require 'spec_helper'

describe ActsAsAmico do
  before :all do
    FakeWeb.allow_net_connect = false

    @all_resp = '<rest_objects type="array">
                  <rest_object><id>123</id><name>Blah</name><description>Some stuff</description></rest_object>
                  <rest_object><id>321</id><name>Blah</name><description>Some stuff</description></rest_object>
                </rest_objects>'
    @resp_123 = '<rest_object><id>123</id><name>Blah</name><description>Some stuff</description></rest_object>'
    @resp_321 = '<rest_object><id>321</id><name>Blah</name><description>Some stuff</description></rest_object>'

    FakeWeb.register_uri(:get, "http://api.sample.com/rest_objects/123.xml", :body => @resp_123, :status => ["200", "OK"])
  end
  after :all do
    FakeWeb.allow_net_connect = true
  end
  before :each do
    @usera = Factory :user
    @admin = Factory :admin
    @rest_object = RestObject.find(321)
  end

  it "should allow following an ActiveResource object" do
    @usera.class.amico_key.should eq("id")
    @admin.class.amico_key.should eq("name")
  end
end