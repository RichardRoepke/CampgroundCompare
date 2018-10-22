module ApplicationHelper

  def generate_title (page_title)
    if page_title.present?
      return 'Campground Compare: ' + page_title
    else
      return 'Campground Compare'
    end
  end

  def header_generator(body, url)
    content_tag :li, class: 'nav-item' do
      link_to(body, url, class: 'nav-link', method: :get)
    end
  end

  def tab_generator(body, url, icon='', method=:get)
    active = ' active' if current_page?(url)
    if url.present?
      content_tag :li, class: 'nav-item' do
        link_to(icon_handler(body, icon), url, class: 'nav-link' + active.to_s, method: method)
      end
    else
      content_tag :li, class: 'nav-item' do
        content_tag(:div, icon_handler(body, icon), class: 'nav-link disabled active')
      end
    end
  end

  def icon_handler(body, icon)
    return content_tag('i', '', class: icon) + ' ' + body if icon.present?
    return body
  end

  def field_value_styler(field, value)
    concat(content_tag('b', field) + ' ' + value.to_s)
    tag('br')
  end
end
