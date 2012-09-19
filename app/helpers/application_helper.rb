module ApplicationHelper
  def ie_tag(name = :html, attrs = {}, &block)
    attrs.symbolize_keys!
    haml_concat("<!--[if lt IE 7]> #{ tag(name, add_class('ie ie6 lte9 lte8 lte7', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if IE 7]> #{ tag(name, add_class('ie ie7 lte9 lte8 lte7', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if IE 8]> #{ tag(name, add_class('ie ie8 lte9 lte8', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if IE 9]> #{ tag(name, add_class('ie ie9 lte9', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if gt IE 9]> #{ tag(name, add_class('', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if !IE]><!-->".html_safe)
    haml_tag name, attrs do
      haml_concat("<!--<![endif]-->".html_safe)
      block.call
    end
  end

  def ie_html(attrs = {}, &block)
    ie_tag(:html, attrs, &block)
  end

  private
    def add_class(name, attrs)
      classes = attrs[:class] || ''
      classes.strip!
      classes = ' ' + classes unless classes.blank?
      classes = name + classes
      attrs.merge(class: classes)
    end
end
