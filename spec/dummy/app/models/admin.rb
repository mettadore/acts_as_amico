class Admin < ActiveRecord::Base
  is_amico :amico_key => "name"
  validates_uniqueness_of :name
  before_validation :set_name

  private

  def set_name
    self.name = "Admin_#{random}" if not self.name
  end
end
