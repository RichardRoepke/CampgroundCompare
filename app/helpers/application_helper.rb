module ApplicationHelper

  def generate_title (page_title)
    if page_title.present?
      return 'Campground Compare: ' + page_title
    else
      return 'Campground Compare'
    end
  end

  def link_to_in_li(body, url, html_options = {})
    active = "active" if current_page?(url)
    content_tag :li, class: active do
      link_to body, url, html_options
    end
  end
end
