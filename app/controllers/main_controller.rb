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
            changes.each do |entry|
              new_entry = MarkedPark.new(entry)
              new_entry.save
            end
            redirect_to marked_park_index_path
          end
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
  end

  def home
  end

  def password
    @user = User.find(current_user.id)
  end

  private
  def get_changed_since(date, page = 1, per_page = 100)
    result_array = []

    request = Typhoeus::Request.get('https://centralcatalogue.com/api/v1/locations?changedSince=' + date + '&page=' + page.to_s + '&per_page=' + per_page.to_s,
                                    headers: {'x-api-key' => '3049ae6c-1ba8-463e-a18b-c511fd7ec0b2'},
                                    :ssl_verifyhost => 0) #Server is set as verified but without proper certification.

    temp_response = JSON.parse(request.response_body)
    response = hash_string_to_sym(temp_response)

    response[:data].each do |value|
      result_array.push(uuid: value[:uuid], name: value[:name], status: 'FINE')
    end

    if response[:totalPages] > page
      if response[:totalPages] > 10 && params[:ignore_wait] != '1'
        result_array = ['Operation aborted due to the excessive time required. If you wish to proceed, please select the checkbox when resubmitting the form.']
      else
        result_array = result_array + get_changed_since(date, (page + 1))
      end
    end

    return result_array
  end

  def hash_string_to_sym(input_hash)
    result_hash = {}

    input_hash.each do |sym, value|
      if value.is_a?(Hash)
        result_hash[sym.to_sym] = hash_string_to_sym(value)
      elsif value.is_a?(Array)
        result_hash[sym.to_sym] = array_string_to_sym(value)
      else
        result_hash[sym.to_sym] = value
      end
    end

    return result_hash
  end

  def array_string_to_sym(input_hash)
    result_hash = []

    input_hash.each do |value|
      if value.is_a?(Hash)
        result_hash.push hash_string_to_sym(value)
      elsif value.is_a?(Array)
        result_hash.push array_string_to_sym(value)
      else
        result_hash.push value
      end
    end

    return result_hash
  end
end
