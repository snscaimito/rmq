$:.push File.expand_path("../lib", __FILE__)
require 'rmq/version'

Gem::Specification.new do |s|
  s.name        = 'rmq'
  s.version     = RMQ::VERSION
  s.date        = '2012-02-07'
  s.summary     = "Ruby MQ client wrapper"
  s.description = "Ruby wrapper around MQ series client library"
  s.authors     = ["Stephan Schwab"]
  s.email       = 'sns@caimito.net'
  s.files       = ["lib/rmq.rb"]
  s.homepage    = 'http://rubygems.org/gems/rmq'

  s.files = Dir.glob("lib/**/*.rb")
  s.test_files  = Dir.glob("{spec}/**/*.rb")

  s.add_development_dependency 'rspec', '~> 2.7'
  s.add_development_dependency 'ffi'
end
