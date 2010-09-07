module Export
  module Base
    private

    def Base.export(sql, basename)
      # remove any existing tmp file
      path = Base.tmp_path basename
      path.unlink if path.exist?

      # ensure the /public/export directory exists
      target = Base.public_path basename
      target.dirname.mkdir unless target.dirname.exist?

      # dump to csv and move to /public/export
      ActiveRecord::Base.connection.execute(sql % path)
      path.rename target
    end

    def Base.tmp_path(basename)
      Pathname.new File.join(Dir.tmpdir, basename)
    end

    def Base.public_path(basename)
      Pathname.new File.join(RAILS_ROOT, "public", "export", basename)
    end
  end
end
