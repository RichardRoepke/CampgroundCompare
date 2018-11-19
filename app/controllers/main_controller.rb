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
      added = 0

      changes = get_changed_since(params[:date_since], params[:database])

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
                           database: params[:database])
  rescue => exception
    redirect_to check_path(date_since: params[:date_since],
                           database: params[:database]),
                           alert: 'A problem occurred. Please adjust your parameters try again.'
  end

  def add_parks
    added = 0
    old = 0
    failed = 0
    invalid = (params[:ignore_invalid] == '1')
    redirect = (params[:redirect] == '1')

    PendingPark.all.each do |park|
      if park.awaiting_check?
        if park.rvparky_id.present?
          result = add_rvparky_id_park(park.rvparky_id, invalid, redirect)
        else
          result = add_new_park(park.uuid, park.slug, invalid, redirect)
        end

        case result
        when 'ADDED'
          park.status = :added
        when 'NOT ADDED'
          park.status = :unneeded
        else
          park.status = :failed
        end

        park.save
      end
    end

    PendingPark.all.each do |park|
      unless park.awaiting_check?
        added += 1 if park.added?
        old += 1 if park.unneeded?
        failed += 1 if park.failed?
        park.destroy!
      end
    end

    if added > 0
      flash[:ADDED_SUCCESS] = added.to_s + " new parks were marked."
    end

    if old > 0
      flash[:OLD_NOTICE] = old.to_s + " parks had no differences or were already marked."
    end

    if failed > 0
      flash[:FAILED_ALERT] = failed.to_s + " parks failed to be included."
    end

    redirect_to marked_park_index_path
  rescue => exception
    redirect_to check_path(redirect: params[:redirect],
                           invalid: params[:ignore_invalid]),
                           alert: 'A problem occurred. Please adjust your parameters try again.'
  end

  def pending_park
    @result = {}

    @result[:awaiting_check] = PendingPark.where(status: :awaiting_check).count
    @result[:added] = PendingPark.where(status: :added).count
    @result[:unneeded] = PendingPark.where(status: :unneeded).count
    @result[:failed] = PendingPark.where(status: :failed).count

    if @result.sum{ |k,h| h }.to_i != params[:totalParks].to_i
      @result = "DONE"
    end

    render :poll_pending_parks, :content_type => 'text/json'
  end

  def home
  end

  def report
    @report_type = 'park_status'
    @report_type = params[:report]
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

  def add_new_park(uuid, slug, invalid, redirect, catalogue_hash=nil, rvparky_hash=nil, rvparky_id=nil)
    catalogue_response = catalogue_hash
    catalogue_response = get_catalogue_location(uuid) if catalogue_response.blank? && uuid.present?

    rvparky_response = rvparky_hash
    rvparky_response = get_rvparky_location(slug) if rvparky_response.blank? && slug.present?

    if catalogue_response.is_a?(Hash)
      name_input = catalogue_response[:name]
    elsif rvparky_response.is_a?(Hash)
      name_input = rvparky_response[:name]
    else
      name_input = "UNKNOWN"
    end

    if rvparky_id.present?
      id_input = rvparky_id
    else
      id_input = rvparky_response[:id]
    end

    result = "NOT FOUND"

    if rvparky_reponse.blank? || rvparky_response[:category] == 'RvPark'
      new_entry = MarkedPark.create({ uuid: uuid,
                                      name: name_input,
                                      slug: slug,
                                      rvparky_id: id_input,
                                      status: nil,
                                      editable: false })
      if new_entry.save
        new_entry.update_status(catalogue_response, rvparky_response)
        new_entry.follow_301(catalogue_response, rvparky_response) if new_entry.status.include?('301')

        if (invalid.present? && !(new_entry.editable?)) || new_entry.status == 'DELETE ME'
          new_entry.destroy
          result = "NOT ADDED"
        else
          result = "ADDED"
        end
      else
        result = "NOT ADDED"
      end
    else # If rvparky_reponse is present but the location isn't an RvPark, don't add it.
      result = "NOT ADDED"
    end

    return result
  rescue => exception
    puts '==================================================================================='
    puts uuid.to_s + ', ' + slug.to_s + ', ' + rvparky_id.to_s
    puts '==================================================================================='
    puts exception
    puts '==================================================================================='
    return 'EXCEPTION'
  end

  def add_rvparky_id_park(rvparky_id, invalid, redirect)
    rvparky_response = get_rvparky_location(rvparky_id.to_s)
    catalogue_response = get_catalogue_location(rvparky_response[:slug])

    uuid_input = catalogue_response[:uuid] if catalogue_response.is_a?(Hash)
    slug_input = rvparky_response[:slug] if rvparky_response.is_a?(Hash)

    if uuid_input.present? || slug_input.present?
      return add_new_park(uuid_input, slug_input, invalid, redirect, catalogue_response, rvparky_response, rvparky_id)
    else
      return 'FAILED'
    end
  end
end
