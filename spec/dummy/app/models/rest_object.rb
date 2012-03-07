class RestObject < ActiveResource::Base

  acts_as_amico :amico_key => "name"
  self.site = "http://api.sample.com"

  self.format = :xml

end
