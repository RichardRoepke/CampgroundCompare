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
    @name = @park.name
    @slug = @park.slug
    @uuid = @park.uuid
  end

  def update
    if params[:commit] == 'Follow 301 Code'
      park = MarkedPark.find(params[:id])
      result = park.follow_301

      flash[result[:status]] = result[:message]

      if result[:status].include?("SUCCESS")
        redirect_to marked_park_index_path(page: session[:page])
      else
        redirect_back(fallback_location: root_path)
      end
    else
      park = MarkedPark.find(params[:id])
      park.name = params[:marked_park][:name] if params[:marked_park][:name].present?
      park.uuid = params[:marked_park][:uuid] if params[:marked_park][:uuid].present?
      if params[:marked_park][:slug].present? && park.slug != params[:marked_park][:slug]
        park.slug = params[:marked_park][:slug]
        # Updating the slug on the Catalogue, since they are used to match up parks
        # with RVParky. RVParky doesn't store uuids so we don't worry about updating them.
        update_catalogue_location(park.uuid, 'location[slug]=' + params[:marked_park][:slug]) if park.uuid.present?
      end
      park.update_status
      park.destroy if park.status == 'DELETE ME'
      park.save if park.valid?

      if park.present?
        flash[:success] = 'Park was successfully updated.'
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
      redirect_to marked_park_path(@park), alert: 'Marked Park is unable to have its differences resolved. Please check that the UUID and Slug are valid.'
    end
  end

  def delete
    @park = MarkedPark.find(params[:id])

    if params[:commit].present? && params[:commit].include?('Remove')
      flash[:ALERT] = @park.name + ' has been removed from the list.'
      @park.destroy
      redirect_to marked_park_index_path(page: session[:page])
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
    if params[:commit].include?('301 Redirects')
      redirect_parks = MarkedPark.page(params[:page]).where('status LIKE :search', search: "%301%")
      follow_number = 0
      redirect_parks.each do |park|
        follow_result = park.follow_301
        follow_number += 1 if follow_result[:status].include?("SUCCESS")
      end

      fill_result = { status: 'SUCCESS', message: follow_number.to_s + " parks were corrected." } if follow_number > 0
      fill_result = { status: 'ALERT', message: "No parks were found or corrected." } if follow_number == 0
    elsif params[:commit].include?('Catalogue Lacks Information')
      fill_result = autocomplete_parks(true, false, false)
    elsif params[:commit].include?('RVParky Lacks Information')
      fill_result = autocomplete_parks(false, true, false)
    elsif params[:commit].include?('Both Lack Information')
      fill_result = autocomplete_parks(true, false, true)
    elsif params[:commit].include?('Remove All Entries with Invalid Slugs')
      remove_result = autoremove_parks(true, false)
    elsif params[:commit].include?('Remove All Entries with Invalid UUIDs')
      remove_result = autoremove_parks(false, true)
    elsif params[:commit].include?('Multiple Tasks')
      fill_tasks = [params['catalogue_blank'] == '1',
                    params['rvparky_blank'] == '1',
                    params['both_blank'] == '1']

      remove_tasks = [params['invalid_slug'] == '1',
                params['invalid_uuid'] == '1']

      fill_result = autocomplete_parks(fill_tasks[0], fill_tasks[1], fill_tasks[2]) if fill_tasks.any?
      remove_result = autoremove_parks(remove_tasks[0], remove_tasks[1]) if remove_tasks.any?

      unless fill_tasks.any? || remove_tasks.any?
        flash[:WARNING] = 'No autocompletion tasks were selected'
        redirect_to marked_park_autocomplete_path and return
      end
    end

    flash[fill_result[:status]] = fill_result[:message] if fill_result.present?
    flash[remove_result[:status]] = remove_result[:message] if remove_result.present?
    redirect_to marked_park_index_path
  end

  def autocomplete_parks(do_catalogue, do_rvparky, do_both)
    output = { status: 'INFO', message: ''}

    num_completed = 0

    MarkedPark.find_each do |park|
      park.update_status
      park.destroy if park.status == 'DELETE ME'
      park.save if park.valid?

      if park.valid? && park.editable?
        if do_catalogue.present? && park.status == 'CATALOGUE LACKS INFORMATION'
          result = update_single_park(park.id, park.get_blank_differences(true, false))
          num_completed += 1 if result[:catalogue][:status].include?('SUCCESS')
        elsif do_rvparky.present? && park.status == 'RVPARKY LACKS INFORMATION'
          result = update_single_park(park.id, park.get_blank_differences(false, true))
          num_completed += 1 if result[:rvparky][:status].include?('SUCCESS')
        elsif do_both.present? && park.status == 'BOTH LACK INFORMATION'
          result = update_single_park(park.id, park.get_blank_differences(true, true))
          num_completed += 1 if result[:catalogue][:status].include?('SUCCESS') && result[:rvparky][:status].include?('SUCCESS')
        end

        park.save
      end
    end

    output[:message] = num_completed.to_s + ' parks were automatically completed.'
    output[:status] = 'SUCCESS' if num_completed > 0

    return output
  end

  def autoremove_parks(do_slug, do_uuid)
    output = { status: 'INFO', message: '' }

    num_completed = 0

    MarkedPark.find_each do |park|
      park.update_status
      park.destroy if park.status == 'DELETE ME'
      park.save if park.valid?

      if park.valid?
        if do_slug.present? && park.status == 'SLUG IS MISSING'
          num_completed += 1 if park.destroy
        elsif do_uuid.present? && park.present? && park.status == 'UUID IS MISSING'
          num_completed += 1 if park.destroy
        end
      end
    end

    output[:message] = num_completed.to_s + ' parks were automatically removed.'
    output[:status] = 'WARNING' if num_completed > 0

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
end