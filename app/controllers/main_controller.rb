require 'get_rvparky_updates'
require 'web_services_calls'

class MainController < ApplicationController

  def check
    @since = params[:date_since] if params[:date_since].present?
    @ignore = (params[:wait] == '1') if params[:wait].present?

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
    added = 0

    if Date.parse(params[:date_since]) < Date.current
      ignore = params[:ignore_wait] == '1'
      changes = get_changed_since(params[:date_since], params[:database], ignore)

      if changes[:catalogue].present?
        if changes[:catalogue].is_a?(String)
          problem[:catalogue] = 'Catalogue: ' + changes[:catalogue]
        else
          changes[:catalogue].each do |entry|
            new_entry = MarkedPark.new({ uuid: entry[:uuid],
                                         name: entry[:name],
                                         slug: entry[:slug],
                                         status: nil,
                                         editable: false })
            new_entry.update_status(entry, nil)
            added += 1 if new_entry.status != 'DELETE ME' && new_entry.save
          end
        end
      end

      if changes[:rvparky].present?
        if changes[:rvparky].is_a?(String)
          problem[:rvparky] = 'RVParky: ' + changes[:rvparky]
        else
          changes[:rvparky].each do |entry|
            result = get_catalogue_location(entry[:slug])

            if result.is_a?(Hash)
              uuid = result[:uuid]
              catalogue_response = result
            else
              uuid = 'NULL'
            end

            new_entry = MarkedPark.new({ uuid: uuid,
                                         name: entry[:name],
                                         slug: entry[:slug],
                                         status: nil,
                                         editable: false })
            new_entry.update_status(catalogue_response, entry)
            added += 1 if new_entry.status != 'DELETE ME' && new_entry.save
          end
        end
      end
    else
      problem[:general] = 'Please select a date before today\'s date.'
    end

    if problem[:catalogue].present? || problem[:rvparky].present? || problem[:general].present?
      flash['CATALOGUE ALERT'] = problem[:catalogue] if problem[:catalogue].present?
      flash['RVPARKY ALERT'] = problem[:rvparky] if problem[:rvparky].present?
      flash['NOTICE'] = problem[:general] if problem[:general].present?
      redirect_to check_path(date_since: params[:date_since],
                             wait: params[:ignore_wait],
                             database: params[:database])
    else
      if added > 0
        flash[:success] = added.to_s + ' new parks were marked as changed.'
        redirect_to marked_park_index_path
      else
        flash['NOTICE'] = 'No new changes were found.'
        redirect_to check_path(date_since: params[:date_since],
                             wait: params[:ignore_wait],
                             database: params[:database])
      end
    end
  rescue => exception
    redirect_to check_path(date_since: params[:date_since],
                           wait: params[:ignore_wait],
                           database: params[:database]),
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
end
