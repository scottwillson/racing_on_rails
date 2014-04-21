class CategoriesController < ApplicationController
  def index
    @name = name(params[:name])
    @categories = find_categories(@name).paginate(page: page, per_page: 1000)
  end

  def find_categories(name)
    categories = Category.where("name like ?", "%#{name}%").order(:name)

    if @name.present?
      categories.where("name like ?", "%#{name}%")
    else
      categories
    end
  end


  protected

  def name(value)
    if value
      value.strip
    else
      ""
    end
  end
end
