class MainController < ApplicationController

  def check
    @since = params[:date_since] if params[:date_since].present?
    @ignore = params[:ignore_wait] if params[:ignore_wait].present?
  end

  def check_since
    if params[:commit].present?
      if Date.parse(params[:date_since]) < Date.current
        changes = get_changed_since(params[:date_since])

        if changes.present?
          if changes[0].is_a?(String)
            redirect_to check_path(date_since: params[:date_since], wait: params[:ignore_wait]), alert: changes[0]
          else
            added = 0
            changes.each do |entry|
              new_entry = MarkedPark.new({ uuid: entry[:uuid],
                                           name: entry[:name],
                                           slug: entry[:slug],
                                           status: nil })
              new_entry.update_status(entry, nil)
              added += 1 if new_entry.status != 'DELETE ME' && new_entry.save
            end
            if added > 0
              redirect_to marked_park_index_path, alert: added.to_s + ' new parks were marked as changed.'
            else
              redirect_to check_path(date_since: params[:date_since], wait: params[:ignore_wait]), alert: 'All found parks were already included.'
            end
          end
        else
          redirect_to check_path(date_since: params[:date_since],
                                  wait: params[:ignore_wait]),
                                  alert: 'No valid parks found.'
        end
      else
        redirect_to check_path(date_since: params[:date_since],
                                  wait: params[:ignore_wait]),
                                  alert: 'Please select a date before today\'s date.'
      end
    else
      redirect_to check_path(date_since: params[:date_since],
                                wait: params[:ignore_wait]),
                                alert: 'Index could not be generated. Please adjust your parameters try again.'
    end
  rescue => exception
    redirect_to check_path(date_since: params[:date_since],
                              wait: params[:ignore_wait]),
                              alert: 'A problem occurred. Please adjust your parameters try again.'
    puts '========================================================================='
    puts exception.inspect
    puts '========================================================================='
  end

  def home
  end

  def password
    @user = User.find(current_user.id)
  end

  private
  def get_changed_since(date, page = 1, per_page = 100)
    result_array = []

    request = Typhoeus::Request.get('http://centralcatalogue.com:3200/api/v1/locations?changedSince=' + date + '&page=' + page.to_s + '&per_page=' + per_page.to_s,
                                    headers: { 'x-api-key' => '3049ae6c-1ba8-463e-a18b-c511fd7ec0b2' },
                                    :ssl_verifyhost => 0) #Server is set as verified but without proper certification.

    if request.response_code == 200
      temp_response = JSON.parse(request.response_body)
      response = hash_string_to_sym(temp_response)

      response[:data].each do |value|
        result_array.push(value) unless value[:slug].blank? # No slug, no way to check RV Parky
      end

      if response[:totalPages] > page
        if response[:totalPages] > 10 && params[:ignore_wait] != '1'
          result_array = ['Operation aborted due to the excessive time required. If you wish to proceed, please select the checkbox when resubmitting the form.']
        else
          next_page_array = get_changed_since(date, (page + 1))
          # If next_page_array is a string then an error must have occured so
          # don't append it to the current array.
          result_array = result_array + next_page_array unless next_page_array[0].is_a?(String)
        end
      end
    else
      result_array = ['Response failed.']
    end

    return result_array
  end
end
