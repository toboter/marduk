$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "marduk/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "marduk"
  s.version     = Marduk::VERSION
  s.authors     = ["Tobias Schmidt"]
  s.email       = ["t.schmidt@rubidat.de"]
  s.homepage    = "http://babylon-online.org"
  s.summary     = "Authentication and Autorization against babili."
  s.description = "Authentication and Autorization against babili."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.0"
  s.add_dependency "omniauth-oauth2"
  s.add_dependency "rest-client"
  s.add_dependency "simple_form"

  s.add_development_dependency "sqlite3"
end
