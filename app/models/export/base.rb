module Export
  def Export.export_all
    Event.export
    Race.export
    Result.export
    `rm #{Rails.root}/public/export/*.bz2`
    `tar --create --bzip2 --file=#{Rails.root}/public/export/#{RacingAssociation.current.short_name.downcase}.tar.bz2 #{Rails.root}/public/export/*.*`
    `rm #{Rails.root}/public/export/*.txt`
    `rm #{Rails.root}/public/export/*.csv`
  end
  
  module Base
    private

    def Base.export(sql, basename)
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

    def Base.tmp_path(basename)
      Pathname.new File.join("#{Rails.root}/tmp/export", basename)
    end

    def Base.public_path(basename)
      Pathname.new File.join(RAILS_ROOT, "public", "export", basename)
    end
  end
end
