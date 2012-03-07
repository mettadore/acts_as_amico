class Admin < ActiveRecord::Base
  acts_as_amico :amico_key => :name
  validates_uniqueness_of :name
  validates_presence_of :name
end
