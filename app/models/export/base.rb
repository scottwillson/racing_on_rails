require 'csv'

module Export
  def self.export_all
    Alias.export
    Category.export
    Event.export
    Person.export
    Race.export
    Result.export
    Team.export
    Dir.chdir("#{Rails.root}/public/export") do
      `rm *.bz2` if Dir.glob("*.bz2").present?
      `tar --create --bzip2 --file=#{RacingAssociation.current.short_name.downcase}.tar.bz2 *.*`
      `rm *.txt` if Dir.glob("*.txt").present?
      `rm *.csv` if Dir.glob("*.csv").present?
    end
  end
  
  module Base
    private

    def self.export(sql, basename)
      # remove any existing tmp file
      path = Base.tmp_path basename
      path.unlink if path.exist?
      FileUtils.mkdir_p path.dirname unless path.dirname.exist?
      FileUtils.chmod 0777, path.dirname

      # ensure the /public/export directory exists
      target = Base.public_path basename
      target.dirname.mkdir unless target.dirname.exist?

      # dump to csv and move to /public/export
      ActiveRecord::Base.connection.execute(sql % path)
      path.rename target
    end

    def self.tmp_path(basename)
      Pathname.new File.join("#{Rails.root}/tmp/export", basename)
    end

    def self.public_path(basename)
      Pathname.new File.join(::Rails.root.to_s, "public", "export", basename)
    end
  end
end
