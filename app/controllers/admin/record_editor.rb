# Superclass for controllers that edit model classes inline. Example:
# class Admin::RacersController < Admin::RecordEditor
#   edits :racer
#
# Enforce login as well
class Admin::RecordEditor < ApplicationController

  before_filter :login_required
  layout 'admin/application'

  def self.edits(active_record_symbol, icon = nil)
    @@record_symbol = active_record_symbol
    @@record_class_name = active_record_symbol.to_s.humanize
    if icon.nil?
      @@icon = @@record_symbol.to_s
    else
      @@icon = icon
    end
    
    class_eval <<END
    def new_inline
      @record = #{@@record_class_name}.new(:name => 'New #{@@record_class_name}')
      @icon = @@icon
      render(:partial => '/admin/new_inline')
    end
    
    def toggle_attribute
      record = #{@@record_class_name}.find(params[:id])
      attribute = params[:attribute]
      record.toggle!(attribute)
      render(:partial => '/admin/attribute', :locals => {:record => record, :name => attribute})
    end
END
  end
end