require 'web_services_calls'

class MarkedParkController < ApplicationController
  include CommonFields
  before_action :provide_title

  def index
    # Using the session to mark which index page the user was last at.
    session[:page] = params[:page]

    park_list = MarkedPark.page(params[:page])
    # I have no clue why session changes :exact to "exact".
    park_list = park_list.where(session[:filter]["exact"]) if session[:filter]["exact"].present?
    @parks = park_list.per(12)
    @filter = session[:filter] if session[:filter]["exact"].present? || session[:filter]["inclusive"].present?
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
    @slug = @park.slug if @park.slug.present?
    @uuid = @park.uuid unless @park.uuid.include?('NULL') #uuid must be present. Slug does not.
  end

  def update
    if params[:commit] == 'Follow 301 Code'
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
      redirect_to marked_park_path(@park), alert: 'Marked Park is unable to be quickly edited.'
    end
  end

  def submit_changes
    park = MarkedPark.find(params[:id])

    processed_inputs = process_changes(params)

    catalogue_url = calc_catalogue_url(processed_inputs[:catalogue], park)
    rvparky_url = calc_rvparky_url(processed_inputs[:rvparky], park)

    uuid = '5ac85c35-c512-4ed4-bef1-28118d6c7e9e' # Progressive's uuid. Don't want to accidentially mess something up.

    catalogue_message = { status: 'CAT NONE',
                          message: '' }
    rvparky_message = { status: 'RV NONE',
                        message: '' }

    if catalogue_url.present?
      request = update_catalogue_location(uuid, catalogue_url)

      if request == 201
        catalogue_message[:status] = 'CAT SUCCESS'
        catalogue_message[:message] = 'Central Catalogue: Changes successfully submitted.'
      else
        catalogue_message[:status] = 'CAT ALERT'
        catalogue_message[:message] = 'Central Catalogue: There was an error submitting the changes. Please try again shortly.'
      end
    end

    if rvparky_url.present?
      if true # request.response_code == 201
        rvparky_message[:status] = 'RV SUCCESS'
        rvparky_message[:message] = 'RVParky: Changes successfully submitted.'
      else
        rvparky_message[:status] = 'RV ALERT'
        rvparky_message[:message] = 'RVParky: There was an error submitting the changes. Please try again shortly.'
      end
    end

    old_status = park.status

    if catalogue_message[:status].include? 'SUCCESS'
      park.status = 'BOTH UPDATING' if rvparky_message[:status].include? 'SUCCESS'
      park.status = 'CATALOGUE UPDATING' if rvparky_message[:status].include? 'NONE'
    elsif catalogue_message[:status].include? 'NONE'
      park.status = 'RVPARKY UPDATING' if rvparky_message[:status].include? 'SUCCESS'
    end

    park.editable = (old_status == park.status)
    park.save

    flash[catalogue_message[:status]] = catalogue_message[:message] unless catalogue_message[:status].include?('NONE')
    flash[rvparky_message[:status]] = rvparky_message[:message] unless rvparky_message[:status].include?('NONE')

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
    MarkedPark.find_each do |park|
      park.update_status
      park.destroy if park.status == 'DELETE ME'
      park.save if park.valid?
    end

    flash[:success] = 'All parks have been updated.'
    redirect_to marked_park_index_path
  rescue => exception
    redirect_to marked_park_index_path, alert: 'An error has occurred. Please try again.'
  end

  def autologic
    if params[:commit].include?('Catalogue Lacks Information')
      result = autocomplete_parks(true, false, false)
    elsif params[:commit].include?('RVParky Lacks Information')
      result = autocomplete_parks(false, true, false)
    elsif params[:commit].include?('Both Lack Information')
      result = autocomplete_parks(true, false, true)
    elsif params[:commit].include?('Multiple Tasks')

      tasks = ['catalogue_blank', 'rvparky_blank', 'both_blank']

      continue = false
      tasks_todo = []

      tasks.each do |task|
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
    else
      result = { status: 'WARNING', message: 'Action could not be parsed.'}
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

      if park.valid?
        if do_catalogue.present? && park.status == 'CATALOGUE LACKS INFORMATION'
          # TODO: Figure out an easy and generic way to update parks via web services.
          park.editable = false
          park.status = 'CATALOGUE UPDATING'
        elsif do_rvparky.present? && park.status == 'RVPARKY LACKS INFORMATION'
          # TODO: Figure out an easy and generic way to update parks via web services.
          park.editable = false
          park.status = 'RVPARKY UPDATING'
        elsif do_both.present? && park.status == 'BOTH LACK INFORMATION'
          # TODO: Figure out an easy and generic way to update parks via web services.
          park.editable = false
          park.status = 'BOTH UPDATING'
        end

        park.save
      end
    end

    return output
  end

  def filter
    #
  end

  def filter_logic
    session[:filter] = { exact: {}, inclusive: {} }

    if params[:editable].present?
      session[:filter][:exact][:editable] = params[:editable].include?('TRUE')
    end

    if params[:name].present?
      session[:filter][:exact][:name] = params[:name] if params[:name_exact] == '1'
      session[:filter][:inclusive][:name] = params[:name] if params[:name_exact] == '0'
    end

    redirect_to marked_park_index_path
    #redirect_back(fallback_location: root_path)
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
end