require 'minitest/unit'

module MiniTest
  class Unit
    def Unit.driver
      @@driver ||= nil
    end

    def Unit.driver=(value)
      @@driver = value
    end

    def Unit.results_path
      File.expand_path "#{::Rails.root.to_s}/log/acceptance"
    end

    # puke(PublicPagesTest, test_bar, Page source should include 'BAR')
    def puke(klass, meth, e)
      dir, path = screenshot_path_for(klass, meth)
      File.open("#{MiniTest::Unit.results_path}/index.html", "a") do |f|
        f.puts "<h2>#{meth}</h2>"
        f.puts "<h3>#{e.message}</h3>"
        if e.respond_to? :location
          f.puts "<ol>"
          e.location.each do |line|
            f.puts "<li>#{line}</li>"
          end
          f.puts "</ol>"
        elsif e.respond_to? :exception
          f.puts "<ol>"
          e.exception.backtrace.each do |line|
            f.puts "<li>#{line}</li>"
          end
          f.puts "</ol>"
        end
        File.open("#{MiniTest::Unit.results_path}/index.html", "a") do |f|
          f.puts "<a href='./#{meth[/[^\(]+\(([^\)]+)/,1]}#{meth[/[^\(]+/]}.png'>Screenshot</a><br/>"
          f.puts "<a href='./#{meth[/[^\(]+\(([^\)]+)/,1]}#{meth[/[^\(]+/]}.html'>HTML</a>"
        end
      end
    
      begin
        if MiniTest::Unit.driver
          FileUtils.mkdir_p dir
          MiniTest::Unit.driver.save_screenshot(path)
          File.open("#{MiniTest::Unit.results_path}/#{klass}/#{meth}.html", "w") { |f| f.write MiniTest::Unit.driver.page_source }
        end
      rescue Exception => e
        p e
        e.backtrace.each do |line|
          p line
        end
      end

      e = case e
          when MiniTest::Skip then
            @skips += 1
            "Skipped:\n#{meth}(#{klass}) [#{location e}]:\n#{e.message}\n"
          when MiniTest::Assertion then
            @failures += 1
            "Failure:\n#{meth}(#{klass}) [#{location e}]:\n#{e.message}\n"
          else
            @errors += 1
            bt = MiniTest::filter_backtrace(e.backtrace).join "\n    "
            "Error:\n#{meth}(#{klass}):\n#{e.class}: #{e.message}\n    #{bt}\n"
          end
      @report << e
      e[0, 1]
    end

    def screenshot_path_for(klass, meth)
      dir = "#{MiniTest::Unit.results_path}/#{klass}"
      path = "#{dir}/#{meth}.png"
      [ dir, path ]
    end
  end
end
