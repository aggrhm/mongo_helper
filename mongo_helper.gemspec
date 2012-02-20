# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mongo_helper/version"

Gem::Specification.new do |s|
  s.name        = "mongo_helper"
  s.version     = MongoHelper::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alan Graham"]
  s.email       = ["alan.g.graham@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Helper gem for Mongo}
  s.description = %q{Helper gem for Mongo}

  s.rubyforge_project = "mongo_helper"
	s.add_dependency "activesupport"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
