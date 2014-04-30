class CleanupVersionsBadYaml < ActiveRecord::Migration
  def up
    VestalVersions::Version.all.each do |v|
      begin
        v.changes.inspect
      rescue Psych::SyntaxError, ArgumentError => e
        puts "#{v.id} has bad YAML: #{e.class} #{e}"
        v.destroy!
      end
    end
  end

  def down
    # Nothing to do
  end
end
