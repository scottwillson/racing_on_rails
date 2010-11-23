# encoding: utf-8

Gem::Specification.new do |s|
  s.name = %q{spreadsheet}
  s.version = "0.6.4.1"
  s.date = %q{2010-11-16}

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Hannes Wyss"]
  s.description = %q{Library to read and write MS Excel Spreadsheets}
  s.summary = %q{Read and Write Excel Spreadsheets}
  s.email = %q{hannes.wyss@gmail.com}
  s.files = Dir.glob("bin/*") + Dir.glob("lib/**/*") + %w(LICENSE.txt README.txt)
  s.homepage = %q{http://github.com/scottwillson/spreadsheet/tree/master}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}

  s.add_dependency(%q<ruby-ole>, [">= 1.2.11.1"])

end
