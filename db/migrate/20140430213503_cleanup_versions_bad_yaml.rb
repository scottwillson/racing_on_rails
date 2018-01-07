# frozen_string_literal: true

class CleanupVersionsBadYaml < ActiveRecord::Migration
  def up
    VestalVersions::Version.all.each do |v|
      v.changes.inspect
    rescue Psych::SyntaxError, ArgumentError => e
      puts "#{v.id} has bad YAML: #{e.class} #{e}"
      v.destroy!
    end
  end

  def down
    # Nothing to do
  end
end
