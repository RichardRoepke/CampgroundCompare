module MarkedParkHelper

  def generate_badge(text, editable)
    return content_tag('span', text, class: 'badge badge-warning') if text.include?('UPDATING') && !text.include?('ERROR')
    return content_tag('span', text, class: 'badge badge-danger') unless editable.present?
    return content_tag('span', text, class: 'badge badge-primary')
  end

  def collapse_button_generator(body, modifier)
    url = '#' + body.downcase + modifier + 'Collapse'
    controls = body.downcase + modifier + 'Collapse'

    link_to(body, url, { class: 'btn btn-secondary',
                         'data-toggle'.to_sym => 'collapse',
                         'data-parent'.to_sym => '#accordion' + modifier,
                         role: "button",
                         'aria-expanded'.to_sym => "false",
                         'aria-controls'.to_sym => controls })
  end

  def collapse_generator(name, body_function, array, modifier)
    content_tag(:div, { class: 'collapse',
                        id: name.downcase + modifier + 'Collapse',
                        'data-parent'.to_sym => '#accordion' + modifier }) do
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

  # f is the highly descriptive object handling user input. It's needed so that
  # the fields can be properly checked when the user submits info.
  def generate_quick_fields(f, diff)
    row_class = ''
    row_class = 'table-warning' if diff.mismatch?

    content_tag(:tr, { class: row_class, id: diff.id.to_s }) do
      concat(content_tag(:td, { style: "width: 50%" }) do
        concat(diff.catalogue_field)
        generate_quick_entry(f,
                             'CATALOGUE',
                             'Catalogue_' + diff.catalogue_field,
                             'RVParky_' + diff.rvparky_field,
                             diff.catalogue_value,
                             diff.rvparky_value,
                             diff.catalogue_value,
                             diff.id)
      end)
      concat(content_tag(:td, { style: "width: 50%" }) do
        concat(diff.rvparky_field)
        generate_quick_entry(f,
                             'RVPARKY',
                             'RVParky_' + diff.rvparky_field,
                             'Catalogue_' + diff.catalogue_field,
                             diff.rvparky_value,
                             diff.catalogue_value,
                             diff.rvparky_value,
                             diff.id)
      end)
    end
  end

  # f is the highly descriptive object handling user input. It's needed so that
  # the fields can be properly checked when the user submits info.
  def generate_quick_entry(f, kind, entry_name, mirror_name, entry_value, mirror_value, current_value, id)
    copy_type = { element: entry_name, mirror: mirror_name, copy: 'true' }
    copy_type[kind.to_sym] = 'true'
    copy_type[:blank] = true if entry_value.blank?

    concat(f.text_area(entry_name.to_sym, id: entry_name, value: current_value, hide_label: true, data: { mirror: mirror_name, row: id }))
    concat(f.submit("Copy", type: 'button', data: copy_type, class: "btn btn-success"))
    concat(' ')
    concat(f.submit("Reset", type: 'button', data: { element: entry_name, transfer: entry_value, reset: 'true' }, class: "btn btn-secondary")) if entry_value.present?
    concat(tag('br'))
    concat(content_tag(:i, 'Original Value: ' + entry_value.to_s)) if entry_value.present?
    concat(content_tag(:i, 'Originally Blank')) if entry_value.blank?
  end

  # f is the highly descriptive object handling user input. It's needed so that
  # the fields can be properly checked when the user submits info.
  def generate_quick_global_buttons(f)
    concat(f.submit "Copy All Blank", type: 'button', data: { global: '[data-blank]', type: 'copy' }, class: "btn btn-success")
    concat(' ')
    concat(f.submit "Transfer to Catalogue", type: 'button', data: { global: '[data-catalogue]', type: 'copy' }, class: "btn btn-success")
    concat(' ')
    concat(f.submit "Transfer to RVParky", type: 'button', data: { global: '[data-rvparky]', type: 'copy' }, class: "btn btn-success")
    concat(' ')
    concat(f.submit "Reset All", type: 'button', data: { global: '[data-reset]' }, class: "btn btn-secondary")
    concat(' ')
    concat(f.submit "Submit Form", class: "btn btn-primary", data: { submit: 'true' })
    concat(' ')
    f.submit "Submit and Next", class: "btn btn-primary", data: { submit: 'true' }
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
      concat(membership.name.to_s + ' (' + membership.type + ')')
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
