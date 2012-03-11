# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'acts_as_amico/version'

Gem::Specification.new do |s|
  s.name        = "acts_as_amico"
  s.version     = ActsAsAmico::VERSION
  s.authors     = ["John Metta"]
  s.email       = ["mail@johnmetta.com"]
  s.homepage    = "https://github.com/mettadore/acts_as_amico"
  s.summary     = %q{Rails injectable Relationships (e.g. friendships) backed by Redis}
  s.description = %q{Rails injectable Relationships (e.g. friendships) backed by Redis}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'redis'
  s.add_dependency 'amico'
  s.add_dependency "rails", "~> 3.1"

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'fakeweb'
  s.add_development_dependency 'uuidtools'
end
