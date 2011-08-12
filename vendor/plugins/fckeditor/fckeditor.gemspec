# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require File.expand_path(File.dirname(__FILE__) + "/lib/fckeditor_version")
 
Gem::Specification.new do |s|
  s.name        = "fckeditor"
  s.version     = FckeditorVersion.current
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Scott Rutherford"]
  s.email       = ["scott.willson@gmail.com"]
  s.homepage    = "https://github.com/scottwillson/fckeditor"
  s.summary     = "FCKeditor plugin for Rails"
  s.description = "Adds FCKeditor helpers and code to Rails application"
 
  s.required_rubygems_version = ">= 1.3.6"
 
  s.files        = Dir.glob("{app,lib,public}/**/*") + %w(README CHANGELOG init.rb install.rb)
  s.require_path = 'lib'
end
