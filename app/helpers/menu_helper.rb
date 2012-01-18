module MenuHelper
  def build_menu
    article_categories = ArticleCategory.all( :conditions => ["parent_id = 0"], :order => "position")
    discipline_names = Discipline.find_all_names
    render :partial => "shared/menu", :locals => { :article_categories => article_categories, :discipline_names => discipline_names }
  end
end
