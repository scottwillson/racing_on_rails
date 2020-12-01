# frozen_string_literal: true

module EditableHelper
  def editable(object, attribute, options = {})
    object_name = ActiveModel::Naming.singular(object)

    value = if options[:value].nil?
              object.send(attribute)
            else
              options[:value]
            end

    value = truncate(value, length: options[:length]) if options[:length].present?

    _object_name = if options[:as].present?
                     options[:as].to_s
                   else
                     object_name
                   end

    tag.div(class: "editable",
            id: "#{_object_name}_#{object.to_param}_#{attribute}",
            data: {
              id: object.id,
              url: url_for(controller: _object_name.pluralize, action: "update_attribute", id: object.to_param),
              model: _object_name,
              attribute: attribute,
              original: value
            }) do
      value.to_s
    end
  end
end
