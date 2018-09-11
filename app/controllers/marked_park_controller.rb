require 'web_services_calls'

class MarkedParkController < ApplicationController
  include CommonFields
  before_action :provide_title

  def index
    # Using the session to mark which index page the user was last at.
    session[:page] = params[:page]

    park_list = MarkedPark.page(params[:page])

    park_list = park_list.where('name LIKE :search OR slug LIKE :search OR uuid LIKE :search OR status LIKE :search',
                                search: "%#{session[:filter]}%") if session[:filter].present?
    park_list = park_list.where("editable = '1'") if session[:editable].present?

    if park_list.length == 0 && (session[:filter].present? || session[:editable].present?)
      session[:filter] = nil
      session[:editable] = nil
      flash.now[:FILTER_WARNING] = 'No parks found. Filter removed.'
      park_list = MarkedPark.page(params[:page])
    end

    @filter = session[:filter] if session[:filter].present?
    @editable = true if session[:editable].present?
    @parks = park_list.per(12)
  end

  def show
    @catalogue = nil
    @rvparky = nil

    @park = MarkedPark.find(params[:id])

    if @park.uuid.present?
      catalogue_temp = get_catalogue_location(@park.uuid)
      @catalogue = CatalogueLocationValidator.new(catalogue_temp) if catalogue_temp.present? && catalogue_temp.is_a?(Hash)
    end

    if @park.slug.present?
      rvparky_temp = get_rvparky_location(@park.slug)
      @rvparky = RvparkyLocationValidator.new(rvparky_temp) if rvparky_temp.present? && rvparky_temp.is_a?(Hash)
    end

    if @rvparky.present? && @catalogue.present?
      @park.update_status(catalogue_temp, rvparky_temp)
      @park.destroy if @park.status == 'DELETE ME'
      @park.save if @park.valid?

      if @park.present?
        @differences = @park.differences
      else
        flash[:success] = 'Differences were resolved since last checked.'
        redirect_to marked_park_index_path
      end
    end
  end

  def edit
    @park = MarkedPark.find(params[:id])
    @slug = @park.slug if @park.slug.present? && !@park.slug.include?('NULL')
    @uuid = @park.uuid unless @park.uuid.include?('NULL') #uuid must be present. Slug does not.
  end

  def update
    if params[:commit] == 'Follow 301 Code'
      park = MarkedPark.find(params[:id])
      result = park.follow_301

      flash[result[:status]] = result[:message]

      if result[:status].include?("SUCCESS")
        # TODO: Update Central Catalogue database.
        redirect_to marked_park_index_path(page: session[:page])
      else
        redirect_back(fallback_location: root_path)
      end
    else
      park = MarkedPark.find(params[:id])
      park.uuid = params[:marked_park][:uuid]
      park.slug = params[:marked_park][:slug]
      park.update_status
      park.destroy if park.status == 'DELETE ME'
      park.save if park.valid?

      if park.valid?
        flash[:success] = 'Park was successfully updated.'
        redirect_to marked_park_index_path(page: session[:page])
      elsif park.present?
        flash[:success] = 'No differences found after update.'
        redirect_to marked_park_index_path(page: session[:page])
      else
        flash[:ALERT] = 'Invalid Information.'
        redirect_back(fallback_location: root_path)
      end
    end
  end

  def quick
    @park = MarkedPark.find(params[:id])

    if @park.editable?
      @catalogue = nil
      @rvparky = nil

      if @park.uuid.present?
        catalogue_temp = get_catalogue_location(@park.uuid)
        @catalogue = CatalogueLocationValidator.new(catalogue_temp) if catalogue_temp.present? && catalogue_temp.is_a?(Hash)
      end

      if @park.slug.present?
        rvparky_temp = get_rvparky_location(@park.slug)
        @rvparky = RvparkyLocationValidator.new(rvparky_temp) if rvparky_temp.present? && rvparky_temp.is_a?(Hash)
      end

      if @rvparky.present? && @catalogue.present?
        @park.update_status(catalogue_temp, rvparky_temp)
        @park.destroy if @park.status == 'DELETE ME'
        @park.save if @park.valid?

        if @park.present? && @park.editable?
          @differences = @park.differences
        else
          redirect_to marked_park_path(@park), alert: 'Park is no longer editable.' if @park.present?
          redirect_to marked_park_index_path, alert: 'Differences were resolved since last checked.' unless @park.present?
        end
      else
        redirect_to marked_park_path(@park), alert: 'Could not connect to the required web services.'
      end
    else
      redirect_to marked_park_path(@park), alert: 'Marked Park is unable to have its differences resolved.'
    end
  end

  def submit_changes
    result = update_single_park(params[:id], process_changes(params))

    flash[result[:catalogue][:status]] = result[:catalogue][:message] unless result[:catalogue][:status].include?('NONE')
    flash[result[:rvparky][:status]] = result[:rvparky][:message] unless result[:rvparky][:status].include?('NONE')

    if params["commit"] == 'Submit and Next'
      target = park

      loop do
        target = target.next
        break if target.blank? || target.editable?
      end

      redirect_to marked_park_quick_path(target.id) if target.present?
      redirect_to marked_park_index_path, alert: 'No further parks found.' unless target.present?
    else
      redirect_to marked_park_index_path(page: session[:page])
    end
  end

  def status
    puts params.inspect
    if params[:format].present?
      single_park = MarkedPark.find(params[:format])
      single_park.update_status
      single_park.destroy if single_park.status == 'DELETE ME'
      single_park.save if single_park.valid?

      flash[:success] = single_park.name + ' has been updated.' if single_park.present?
      flash[:success] = 'No differences found after the park has been updated.' if single_park.blank?
      redirect_to marked_park_index_path(page: session[:page])
    else
      MarkedPark.find_each do |park|
        park.update_status
        park.destroy if park.status == 'DELETE ME'
        park.save if park.valid?
      end

      flash[:success] = 'All parks have been updated.'
      redirect_to marked_park_index_path
    end
  rescue => exception
    redirect_to marked_park_index_path, alert: 'An error has occurred. Please try again.'
  end

  def autologic
    result = { status: 'WARNING', message: 'Action could not be parsed.'}

    if params[:commit].include?('301 Redirects')
      redirect_parks = MarkedPark.page(params[:page]).where('status LIKE :search', search: "%301%")
      follow_number = 0
      redirect_parks.each do |park|
        follow_result = park.follow_301
        if follow_result[:status].include?("SUCCESS")
          # TODO: Update Central Catalogue
          follow_number += 1
        end
      end

      result = { status: 'SUCCESS', message: follow_number.to_s + " parks were corrected." } if follow_number > 0
      result = { status: 'ALERT', message: "No parks were found or corrected." } if follow_number == 0
    elsif params[:commit].include?('Catalogue Lacks Information')
      result = autocomplete_parks(true, false, false)
    elsif params[:commit].include?('RVParky Lacks Information')
      result = autocomplete_parks(false, true, false)
    elsif params[:commit].include?('Both Lack Information')
      result = autocomplete_parks(true, false, true)
    elsif params[:commit].include?('Multiple Tasks')
      possible_tasks = ['catalogue_blank', 'rvparky_blank', 'both_blank']
      tasks_todo = []
      continue = false

      possible_tasks.each do |task|
        # I have no clue why bootstrap forms renders a selected checkbox as '1'
        continue = true if params[task] == '1'
        tasks_todo.push(params[task] == '1')
      end

      if continue.present?
        result = autocomplete_parks(tasks_todo[0], tasks_todo[1], tasks_todo[2])
      else
        flash[:WARNING] = 'No autocompletion tasks were selected'
        redirect_to marked_park_autocomplete_path and return
      end
    end

    flash[result[:status]] = result[:message]
    redirect_to marked_park_index_path
  end

  def autocomplete_parks(do_catalogue, do_rvparky, do_both)
    output = { status: 'ALERT', message: 'COMPLETED SUCCESSFULLY.'}

    MarkedPark.find_each do |park|
      park.update_status
      park.destroy if park.status == 'DELETE ME'
      park.save if park.valid?

      if park.valid? && park.editable?
        if do_catalogue.present? && park.status == 'CATALOGUE LACKS INFORMATION'
          result = update_single_park(park.id, park.get_blank_differences(true, false))
        elsif do_rvparky.present? && park.status == 'RVPARKY LACKS INFORMATION'
          result = update_single_park(park.id, park.get_blank_differences(false, true))
        elsif do_both.present? && park.status == 'BOTH LACK INFORMATION'
          result = update_single_park(park.id, park.get_blank_differences(true, true))
        end

        park.save
      end
    end

    return output
  end

  def filter_logic
    if params[:commit] == 'Clear'
      session[:filter] = nil
      session[:editable] = nil
    end

    if params[:commit] == 'Filter'
      session[:filter] = params[:filter] if params[:filter].present?
      session[:editable] = true if params[:editable] == '1'
    end

    redirect_to marked_park_index_path
  end

  def process_changes(form_inputs)
    result = { catalogue: {},
               rvparky: {} }

    form_inputs.each do |key, value|
      if key.to_s.include?('Catalogue_')
        cut_string = key.to_s.remove('Catalogue_')
        result[:catalogue][cut_string.to_sym] = value
      elsif key.to_s.include?('RVParky_')
        cut_string = key.to_s.remove('RVParky_')
        result[:rvparky][cut_string.to_sym] = value
      end
    end

    return result
  end

  def calc_catalogue_url(catalogue_hash, park)
    result = ''

    catalogue_hash.each do |key, value|
      corresponding_diff = park.differences.find_by(catalogue_field: key)
      unless corresponding_diff.catalogue_value == value
        result += '%26' unless result.blank?
        result += 'location%5B' + key.to_s + '%5D=' + value.to_s
      end
    end

    result.gsub!(' ', '%20') unless result.blank?

    return result
  end

  def calc_rvparky_url(rvparky_hash, park)
    return 'foobar' # Once the API for updating RVParky is known, this will be filled in.
  end

  private
  def provide_title
    @title = 'Parks'
  end

  def calculate_new_status(catalogue, rvparky)
    # We don't worry about the case where both are none since that should never happen.
    if rvparky.include?("NONE")
      return 'CATALOGUE UPDATING' if catalogue.include?('SUCCESS')
      return 'CATALOGUE ERROR' # Catalogue failed
    end

    if catalogue.include?("NONE")
      return 'RVPARKY UPDATING' if rvparky.include?('SUCCESS')
      return 'RVPARKY ERROR' # RVParky failed
    end

    # Updates were sent to both databases.
    return 'BOTH UPDATING' if catalogue.include?('SUCCESS') && rvparky.include?('SUCCESS')
    return 'CATALOGUE UPDATING, RVPARKY ERROR' if catalogue.include?('SUCCESS') && rvparky.include?('ALERT')
    return 'CATALOGUE ERROR, RVPARKY UPDATING' if catalogue.include?('ALERT') && rvparky.include?('SUCCESS')
    return 'ERROR UPDATING'
  end

  def update_single_park(id, processed_inputs)
    result = { catalogue: { status: 'CAT NONE',
                            message: '' },
               rvparky: { status: 'RV NONE',
                          message: '' } }

    park = MarkedPark.find(id)

    catalogue_url = calc_catalogue_url(processed_inputs[:catalogue], park)
    rvparky_url = calc_rvparky_url(processed_inputs[:rvparky], park)

    if catalogue_url.present?
      request = update_catalogue_location(park.uuid, catalogue_url)

      if request == 201
        result[:catalogue][:status] = 'CAT SUCCESS'
        result[:catalogue][:message] = 'Central Catalogue: Changes successfully submitted.'
      else
        result[:catalogue][:status] = 'CAT ALERT'
        result[:catalogue][:message] = 'Central Catalogue: There was an error submitting the changes. Please try again shortly.'
      end
    end

    if rvparky_url.present?
      if false # request.response_code == 201
        result[:rvparky][:status] = 'RV SUCCESS'
        result[:rvparky][:message] = 'RVParky: Changes successfully submitted.'
      else
        result[:rvparky][:status] = 'RV ALERT'
        result[:rvparky][:message] = 'RVParky: There was an error submitting the changes. Please try again shortly.'
      end
    end

    park.status = calculate_new_status(result[:catalogue][:status], result[:rvparky][:status])

    park.editable = false
    park.save

    return result
  end
end