require 'get_rvparky_updates'
require 'web_services_calls'

class MainController < ApplicationController

  def check
    @since = params[:date_since] if params[:date_since].present?
    @wait = (params[:wait] == '1') if params[:wait].present?
    @invalid = (params[:invalid] == '1') if params[:invalid].present?
    @redirect = (params[:redirect] == '1') if params[:redirect].present?

    if params[:database].present?
      @check_array = [false, false, false]
      @check_array[0] = true if params[:database] == 'CATALOGUE'
      @check_array[1] = true if params[:database] == 'RVPARKY'
      @check_array[2] = true if params[:database] == 'BOTH'
    else
      @check_array = [true, false, false]
    end
  end

  def check_since
    problem = { catalogue: nil,
                rvparky: nil,
                general: nil }

    if Date.parse(params[:date_since]) <= Date.current
      wait = (params[:ignore_wait] == '1')
      redirect = (params[:redirect] == '1')
      invalid = (params[:ignore_invalid] == '1')

      added = 0

      changes = get_changed_since(params[:date_since], params[:database], wait)

      if changes[:catalogue].present?
        if changes[:catalogue].is_a?(String)
          problem[:catalogue] = 'Catalogue: ' + changes[:catalogue]
        else
          added += populate_pending_parks(changes[:catalogue])
        end
      end

      if changes[:rvparky].present?
        if changes[:rvparky].is_a?(String)
          problem[:rvparky] = 'RVParky: ' + changes[:rvparky]
        else
          added += populate_pending_parks(changes[:rvparky])
        end
      end
    else
      problem[:general] = "Please select a date equal to or before today's."
    end

    if problem[:catalogue].present? || problem[:rvparky].present? || problem[:general].present?
      flash['CATALOGUE ALERT'] = problem[:catalogue] if problem[:catalogue].present?
      flash['RVPARKY ALERT'] = problem[:rvparky] if problem[:rvparky].present?
      flash['NOTICE'] = problem[:general] if problem[:general].present?
    else
      if added > 0
        flash[:success] = added.to_s + ' pending parks were marked.'
      else
        flash['NOTICE'] = 'No new changes were found.'
      end
    end

    redirect_to check_path(date_since: params[:date_since],
                               wait: params[:ignore_wait],
                               redirect: params[:redirect],
                               invalid: params[:ignore_invalid],
                               database: params[:database])
  rescue => exception
    redirect_to check_path(date_since: params[:date_since],
                           wait: params[:ignore_wait],
                           redirect: params[:redirect],
                           invalid: params[:ignore_invalid],
                           database: params[:database]),
                           alert: 'A problem occurred. Please adjust your parameters try again.'
  end

  def pending_park
    puts '=========================================================================='
    puts params.inspect
    puts '=========================================================================='

    if rand(0..1) == 0
      @park_status = 'ADDED'
    else
      @park_status = 'OLD'
    end

    render :pending_park, :content_type => 'text/json'
  end

  def home
  end

  def report
    @report_type = ''
    @report_type = params[:report] if params[:report].present?
  end

  def password
    @user = User.find(current_user.id)
  end

  private
  def populate_pending_parks(input_array)
    added = 0

    input_array.each do |input|
      new_entry = PendingPark.new(input)
      added += 1 if new_entry.save
    end

    return added
  end

  def generic_add_park(input_hash, type, redirect, invalid)
    num_added = 0

    input_hash.each do |entry|
      if type == 'RVPARKY'
        rvparky_response = entry
        catalogue_check = get_catalogue_location(entry[:slug])

        if catalogue_check.is_a?(Hash)
          uuid_input = catalogue_check[:uuid]
          catalogue_response = catalogue_check
        else
          uuid_input = 'NULL'
        end
      elsif type == 'CATALOGUE'
        catalogue_response = entry
        uuid_input = entry[:uuid]
      end

      unless MarkedPark.exists?(:uuid => uuid_input)
        new_entry = MarkedPark.create({ uuid: uuid_input,
                                        name: entry[:name],
                                        slug: entry[:slug],
                                        status: nil,
                                        editable: false })
        new_entry.save
        new_entry.update_status(catalogue_response, rvparky_response)
        new_entry.follow_301(catalogue_response, rvparky_response) if redirect.present? && new_entry.status.include?('301')
        new_entry.destroy if (invalid && !(new_entry.editable?)) # Destroy all non-editable parks if we don't want invalid parks.
        new_entry.destroy if new_entry.status == 'DELETE ME'
        num_added += 1 if new_entry.present?
      end
    end

    return num_added
  end
end
