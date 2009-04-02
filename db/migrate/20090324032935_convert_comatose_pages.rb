class ConvertComatosePages < ActiveRecord::Migration
  def self.up
    Page.delete_all
    Page::Version.delete_all
    comatose_pages = Page.connection.select_rows("select id, parent_id, full_path, title, slug, body from comatose_pages")
    comatose_pages.sort_by { |p| (p[2] || "").count("/") }
    comatose_pages.each do |comatose_page|
      page = Page.new(
        :title => comatose_page[3],
        :slug => comatose_page[4],
        :body => comatose_page[5].gsub(/ComatosePage.find_by_path\('([^']+)'\).to_html/, 'render_page("\1")')
      )
      page.id = comatose_page[0]
      
      # Move Home children to root
      if comatose_page[1] != "1"
        page.parent_id = comatose_page[1]
      end
      
      p page
      page.save!
    end
  end

  def self.down
    Page.delete_all
    Page::Version.delete_all
  end
end
