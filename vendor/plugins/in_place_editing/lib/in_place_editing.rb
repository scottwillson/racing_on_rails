module InPlaceEditing
  def self.included(base)
    base.extend(ClassMethods)
  end

  # Example:
  #
  #   # Controller
  #   class BlogController < ApplicationController
  #     in_place_edit_for :post, :title
  #   end
  #
  #   # View
  #   <%= in_place_editor_field :post, 'title' %>
  #
  module ClassMethods
    def in_place_edit_for(object, attribute, options = {})
      class_symbol = self.name.underscore
      define_method("set_#{object}_#{attribute}") do
        @item = object.to_s.camelize.constantize.find(params[:id])
        if @item.respond_to?(:author)
          @item.author = current_person
        end
        @item.send("#{attribute}=", params[:value])
        @item.save!
        # HACK! FIXME
        expire_cache
        render :text => @item.send(attribute).to_s
      end
    end
  end
end
