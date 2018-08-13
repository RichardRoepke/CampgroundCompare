module ApplicationHelper

  def generate_title (page_title)
    if page_title.present?
      return 'Campground Compare: ' + page_title
    else
      return 'Campground Compare'
    end
  end
end
