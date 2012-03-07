class RestObject < ActiveResource::Base

  self.site = "http://api.sample.com"

  self.format = :xml

end
