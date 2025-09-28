module ApplicationHelper
    def error_span(object, field)
    return unless object.errors[field].present?
    
    content_tag(:span, object.errors[field].join(', '),
                class: 'text-danger small')
  end
end
