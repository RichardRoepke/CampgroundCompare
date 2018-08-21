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

  def generate_memberships_entry
    return Proc.new do |membership|
      concat(membership.name + ' (' + membership.type + ')')
    end
  end

  def generate_nearbies_entry
    return Proc.new do |nearby|
      # Central Catalogue only sends the names of nearbies at the moment.
      # When/if it sends more information, this section should be expanded.
      concat(nearby.name)
      concat(tag('br'))
    end
  end

  def generate_payments_entry
    return Proc.new do |payment|
      concat(payment.name) if payment.name.present?
      concat(' (' + payment.abbreviation + ')') if payment.abbreviation.present?
      concat(tag('br'))
    end
  end

  def generate_rates_entry
    return Proc.new do |rate|
      concat(rate.name)
      concat(tag('br'))
      concat(rate.start + ' to ' + rate.end)
      concat(tag('br'))
      concat('Minimum Rate: ' + rate.min_rate)
      concat(tag('br'))
      concat('Maximum Rate: ' + rate.max_rate)
      concat(tag('br'))
      concat('Persons Included: ' + rate.persons.to_s)
      concat(tag('br'))
    end
  end

  def generate_reviews_entry
    return Proc.new do |review|
      concat(review.username + ' (' + review.rating.to_s + ')')
      concat(tag('br'))

      if review.title.present?
        concat(review.title)
        concat(tag('br'))
      end

      concat(review.body)
      concat(tag('br'))
      concat('Created On: ' + review.created)
      concat(tag('br'))

      if review.arrival.present?
        concat('Arrival: ' + review.arrival)
        concat(tag('br'))
      end

      if review.departure.present?
        concat('Departure: ' + review.departure)
        concat(tag('br'))
      end

      concat('UNDER REVIEW') if review.reviewed.present?
    end
  end

  def generate_tags_entry
    return Proc.new do |unit|
      concat(unit.id.to_s + ": " + unit.name)
      concat(tag('br'))

      if unit.description.present?
        concat(unit.description)
        concat(tag('br'))
      end
    end
  end
end
