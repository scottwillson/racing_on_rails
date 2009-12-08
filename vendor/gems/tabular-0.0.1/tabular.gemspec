# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{tabular}
  s.version = "0.0.1.20091207200124"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Scott Willson"]
  s.date = %q{2009-12-07}
  s.description = %q{      Import CSV, tab-delimited, and Excel data. Read with common table interface.
}
  s.email = %q{scott.willson@gmail.com}
  s.files = ["lib/tabular/column.rb", "lib/tabular/columns.rb", "lib/tabular/row.rb", "lib/tabular/support/object.rb", "lib/tabular/table.rb", "lib/tabular.rb", "test/column_test.rb", "test/columns_test.rb", "test/row_test.rb", "test/table_test.rb", "Rakefile"]
  s.homepage = %q{http://butlerpress.com}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Tabular data import and manipulation}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
