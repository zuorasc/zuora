# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "zuora/version"

Gem::Specification.new do |s|
  s.name        = "zuora"
  s.version     = Zuora::Version.to_s
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Josh Martin"]
  s.email       = ["josh.martin@wildfireapp.com"]
  s.homepage    = "http://github.com/wildfireapp/zuora"
  s.summary     = %q{Zuora - ActiveModel backed client for the Zuora API}
  s.description = %q{Zuora - Easily integrate the Zuora SOAP API using ruby objects.}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.extra_rdoc_files = [ "README.md" ]

  s.add_runtime_dependency(%q<savon>, [">= 2.0.0"])
  s.add_runtime_dependency(%q<activesupport>, [">= 3.0.0", "< 4.0.0"])
  s.add_runtime_dependency(%q<activemodel>, [">= 3.0.0", "< 4.0.0"])
  s.add_runtime_dependency(%q<libxml4r>, ['~> 0.2.6'])

  s.add_development_dependency(%q<rake>, ["~> 0.8.7"])
  s.add_development_dependency(%q<guard-rspec>, ["~> 0.6.0"])
  s.add_development_dependency(%q<artifice>, ["~> 0.6.0"])
  s.add_development_dependency(%q<yard>, ["~> 0.7.5"])
  s.add_development_dependency(%q<rspec>, ["~> 2.8.0"])
  s.add_development_dependency(%q<redcarpet>, ["~> 2.1.0"])
  s.add_development_dependency(%q<factory_girl>, ["~> 2.6.4"])
  s.add_development_dependency(%q<appraisal>, ["~> 0.4.1"])
  s.add_development_dependency(%q<sqlite3>, ["~> 1.3.0"])
  s.add_development_dependency('debugger')
end
