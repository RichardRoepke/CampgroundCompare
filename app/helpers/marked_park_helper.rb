module MarkedParkHelper

  def collapse_button_generator(body)
    url = '#' + body.downcase + 'Collapse'
    controls = body.downcase + 'Collapse'

    link_to(body, url, { class: 'btn btn-secondary',
                         'data-toggle'.to_sym => 'collapse',
                         'data-parent'.to_sym => '#accordion',
                         role: "button",
                         'aria-expanded'.to_sym => "false",
                         'aria-controls'.to_sym => controls })
  end

  def collapse_generator(name, body_function, array)
    content_tag(:div, { class: 'collapse',
                        id: name.downcase + 'Collapse',
                        'data-parent'.to_sym => '#accordion' }) do
      content_tag(:div, class: 'card card-body') do
        content_tag(:ul, class: 'list-group') do
          array.each do |item|
            concat(content_tag(:li, class: 'list-group-item') do
              # content_tag seems to generate tags where it was called, so the
              # use of Proc and .call is needed to get it to appear in the
              # proper location.
              body_function.call(item)
            end)
          end
        end
      end
    end
  end

  def generate_amenities_entry
    return Proc.new do |amenity|
      concat(amenity.id.to_s + ': ' + amenity.name + ': ' + amenity.group)
      concat(tag('br'))

      if amenity.token.present?
        concat('Trip Adviser Token: ' + amenity.token)
        concat(tag('br'))
      end

     if amenity.description.present?
        concat('Description: ' + amenity.description)
        concat(tag('br'))
     end
    end
  end

  def generate_cobrands_entry
    return Proc.new do |cobrand|
      concat(cobrand.id.to_s + ': ' + cobrand.name)
      concat(' (' + cobrand.short + ')') if cobrand.short.present?
      concat(' (' + cobrand.code + ')') if cobrand.code.present?
      concat(tag('br'))

      if cobrand.description.present?
        concat('Description: ' + cobrand.description)
        concat(tag('br'))
      end

      if cobrand.notes.present?
        concat('Notes: ' + cobrand.notes)
        concat(tag('br'))
      end
    end
  end

  def generate_images_entry
    return Proc.new do |image|
      concat(image.id.to_s)
      concat(': ' + image.title) if image.title.present?
      concat(' (' + image.alt + ')') if image.alt.present?
      concat(tag('br'))
      if image.caption.present?
        concat(image.caption)
        concat(tag('br'))
      end
    end
  end
end
