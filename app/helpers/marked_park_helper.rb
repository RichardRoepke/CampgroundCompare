module MarkedParkHelper

  def generate_badge(text)
    content_tag('span', text, class: 'badge badge-primary')
  end

  def collapse_button_generator(body, modifier = '')
    url = '#' + body.downcase + modifier + 'Collapse'
    controls = body.downcase + modifier + 'Collapse'

    link_to(body, url, { class: 'btn btn-secondary',
                         'data-toggle'.to_sym => 'collapse',
                         'data-parent'.to_sym => '#accordion',
                         role: "button",
                         'aria-expanded'.to_sym => "false",
                         'aria-controls'.to_sym => controls })
  end

  def collapse_generator(name, body_function, array, modifier = '')
    content_tag(:div, { class: 'collapse',
                        id: name.downcase + modifier + 'Collapse',
                        'data-parent'.to_sym => '#accordion' }) do
      content_tag(:div, class: 'card card-body') do
        content_tag(:ul, class: 'list-group') do
          array.each do |item|
            concat(content_tag(:li, class: 'list-group-item') do
              # content_tag seems to generate tags where it was called, so the
              # use of Proc and .call is needed to get it to appear in the
              # proper location. I suspect that it is due to the use of
              # concat but those are needed to bundle everything properly together.
              body_function.call(item)
            end)
          end
        end
      end
    end
  end

  def generate_input_field
    return Proc.new do |field_name, subsitute_value|
      content_tag()
    end
  end

  def generate_quick_fields(f, diff)
    content_tag(:div, { class: "row" }) do
      concat(content_tag(:div, { class: "col" }) do
        concat(diff.catalogue_field)
        generate_quick_catalogue(f, diff)
      end)
      concat(content_tag(:div, { class: "col" }) do
        concat(diff.rvparky_field)
        generate_quick_rvparky(f, diff)
      end)
    end
  end

  def generate_quick_catalogue(f, diff)
    transfer_type = { element: 'Catalogue_' + diff.catalogue_field, transfer: diff.rvparky_value }
    transfer_type[:blank] = true if diff.catalogue_value.blank?

    concat(f.text_area(('Catalogue_' + diff.catalogue_field).to_sym, id: 'Catalogue_' + diff.catalogue_field, value: diff.catalogue_value, hide_label: true))
    concat(f.submit("Transfer", type: 'button', data: transfer_type, class: "btn btn-outline-primary")) unless diff.rvparky_value.blank?
    concat(f.submit("Reset", type: 'button', data: { element: 'Catalogue_' + diff.catalogue_field, transfer: diff.catalogue_value, reset: 'true' }, class: "btn btn-outline-secondary")) if diff.catalogue_value.present?
    concat(tag('br'))
    concat(content_tag(:i, 'Original Value: ' + diff.catalogue_value.to_s)) if diff.catalogue_value.present?
    concat(content_tag(:i, 'Originally Blank')) if diff.catalogue_value.blank?
  end

  def generate_quick_rvparky(f, diff)
    transfer_type = { element: 'RVParky_' + diff.rvparky_field, transfer: diff.catalogue_value }
    transfer_type[:blank] = true if diff.rvparky_value.blank?

    concat(f.text_area(('RVParky_' + diff.rvparky_field).to_sym, id: 'RVParky_' + diff.rvparky_field, value: diff.rvparky_value, hide_label: true))
    concat(f.submit("Transfer", type: 'button', data: transfer_type, class: "btn btn-outline-primary")) unless diff.catalogue_value.blank?
    concat(f.submit("Reset", type: 'button', data: { element: 'RVParky_' + diff.rvparky_field, transfer: diff.rvparky_value, reset: 'true' }, class: "btn btn-outline-secondary")) if diff.rvparky_value.present?
    concat(tag('br'))
    concat(content_tag(:i, 'Original Value: ' + diff.rvparky_value.to_s)) if diff.rvparky_value.present?
    concat(content_tag(:i, 'Originally Blank')) if diff.rvparky_value.blank?
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

  def generate_cimages_entry
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

  def generate_rimages_entry
    return Proc.new do |image|
      concat('Url: ' + image.url)
      concat(tag('br'))
      concat('Thumb Url: ' + image.thumb)
      concat(tag('br'))
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

      if rate.start.present? && rate.end.present?
        concat(rate.start + ' to ' + rate.end)
        concat(tag('br'))
      end

      if rate.min_rate.present?
        concat('Minimum Rate: ' + rate.min_rate)
        concat(tag('br'))
      end

      if rate.max_rate.present?
        concat('Maximum Rate: ' + rate.max_rate)
        concat(tag('br'))
      end

      if rate.persons.present?
        concat('Persons Included: ' + rate.persons.to_s)
        concat(tag('br'))
      end
    end
  end

  def generate_creviews_entry
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

  def generate_rreviews_entry
    return Proc.new do |review|
      concat(review.author_name + ' (' + review.rating.to_s + ')')
      concat(tag('br'))

      if review.author.present?
        concat('ID: ' + review.author.to_s)
        concat(tag('br'))
      end

      if review.title.present?
        concat(review.title)
        concat(tag('br'))
      end

      if review.text.present?
        concat(review.text)
        concat(tag('br'))
      end

      concat('Created On: ' + review.date)
      concat(tag('br'))

      if review.start.present?
        concat('Arrival: ' + review.start)
        concat(tag('br'))
      end

      if review.end.present?
        concat('Departure: ' + review.end)
        concat(tag('br'))
      end

      if review.comments.present?
        concat('Comments:')
        concat(tag('br'))
        concat(review.comments.to_s)
        concat(tag('br'))
      end
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
