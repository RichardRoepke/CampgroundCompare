class ComparerController < ApplicationController

  def generate
    @since = params[:date_since] if params[:date_since].present?
    @ignore = params[:ignore_wait] if params[:ignore_wait].present?
  end

  def generate_index
    if params[:commit].present?
      if Date.parse(params[:date_since]) < Date.current
        testing = get_changed_since(params[:date_since])

        if testing.present?
          if testing[0].is_a?(String)
            redirect_to generate_path(date_since: params[:date_since], wait: params[:ignore_wait]), alert: testing[0]
          else
            session[:campground_index] = testing
            redirect_to index_path
          end
        end
      else
        redirect_to generate_path(date_since: params[:date_since],
                                  wait: params[:ignore_wait]),
                                  alert: 'Please select a date before today\'s date.'
      end
    else
      redirect_to generate_path(date_since: params[:date_since],
                                wait: params[:ignore_wait]),
                                alert: 'Index could not be generated. Please adjust your parameters try again.'
    end
  rescue => exception
    redirect_to generate_path(date_since: params[:date_since],
                              wait: params[:ignore_wait]),
                              alert: 'A problem occurred. Please adjust your parameters try again.'
  end

  def index
    if session[:campground_index].is_a?(Array)
      @index = session[:campground_index]
    else
      @index = nil
    end
  end

  def entry
  end


  private
  def get_changed_since(date, page = 1, per_page = 100)
    result_array = []

    request = Typhoeus::Request.get('https://centralcatalogue.com/api/v1/locations?changedSince=' + date + '00:00:00&page=' + page.to_s + '&per_page=' + per_page.to_s,
                                    headers: {'x-api-key' => '3049ae6c-1ba8-463e-a18b-c511fd7ec0b2'},
                                    :ssl_verifyhost => 0) #Server is set as verified but without proper certification.

    temp = JSON.parse(request.response_body)
    temper = hash_string_to_sym(temp)

    temper[:data].each do |value|
      result_array.push(uuid: value[:uuid], title: value[:name])
    end

    if temper[:totalPages] > page
      if temper[:totalPages] > 10 && params[:ignore_wait] != '1'
        result_array = ['Generating the foobar would barfoo.']
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
