class MarkedParkController < ApplicationController
  include CommonFields
  before_action :provide_title

  def index
    @parks = MarkedPark.page(params[:page]).per(12)
  end

  def show
    @catalogue = nil
    @rvparky = nil

    @park = MarkedPark.find(params[:id])

    if @park.uuid.present?
      catalogue_temp = get_catalogue_park(@park.uuid)
      @catalogue = CatalogueLocationValidator.new(catalogue_temp) if catalogue_temp.present? && catalogue_temp.is_a?(Hash)
    end

    if @park.slug.present?
      rvparky_temp = get_rvparky_park(@park.slug)
      @rvparky = RvparkyLocationValidator.new(rvparky_temp) if rvparky_temp.present? && rvparky_temp.is_a?(Hash)
    end

    if @rvparky.present? && @catalogue.present?
      @park.update_status(catalogue_temp, rvparky_temp)
      @park.destroy if @park.status == 'DELETE ME'
      @park.save if @park.valid?

      if @park.present?
        @differences = @park.differences
      else
        redirect_to marked_park_index_path, alert: 'Park was already resolved.' unless @park.present?
      end
    end
  end

  def slug
    @park = MarkedPark.find(params[:id])
  end

  def slug_post
    @park = MarkedPark.find(params[:id])

    if params[:commit].include? '301'
      puts Typhoeus::Request.get('https://www.rvparky.com/_ws2/Location/' + @park.slug.to_s,
                                 :ssl_verifyhost => 0).effective_url #Server is set as verified but without proper certification.
    end

    redirect_to marked_park_path(@park)
  end

=begin
  def edit
    @catalogue = nil
    @rvparky = nil

    @park = MarkedPark.find(params[:id])

    if park.uuid.present?
      catalogue_temp = get_catalogue_park(park.uuid)
      @catalogue = CatalogueLocationValidator.new(catalogue_temp) if catalogue_temp.present? && rvparky_temp.is_a?(Hash)
    end

    if park.slug.present?
      rvparky_temp = get_rvparky_park(park.slug)
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
        redirect_to marked_park_index_path, alert: 'Park was already resolved.' unless @park.present?
      end
    end
  end
=end

  def quick
    @park = MarkedPark.find(params[:id])

    if @park.editable?
      @catalogue = nil
      @rvparky = nil
      @previous_values = nil

      # I have no idea why :id turns into 'id' in the session, but otherwise
      # rails won't recognize the presence if ID.
      if session[:previous_edit].present? && session[:previous_edit]['id'] == @park.id
        @previous_values = session[:previous_edit]
      end

      if @park.uuid.present?
        catalogue_temp = get_catalogue_park(@park.uuid)
        @catalogue = CatalogueLocationValidator.new(catalogue_temp) if catalogue_temp.present? && catalogue_temp.is_a?(Hash)
      end

      if @park.slug.present?
        rvparky_temp = get_rvparky_park(@park.slug)
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
          redirect_to marked_park_index_path, alert: 'Park was already resolved.' unless @park.present?
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

    processed_inputs = validate_changes(params)

    if processed_inputs[:status] == 'MATCH'
      # Incase the user has had to rework a submission more than once.
      session[:previous_edit] = nil if session[:previous_edit].present?
      catalogue_changed = ''

      catalogue_changed = process_catalogue(processed_inputs[:catalogue],
                                            park) if processed_inputs[:catalogue].present?

      rvparky_changed = process_rvparky(processed_inputs[:rvparky],
                                        park) if processed_inputs[:rvparky].present?

      uuid = '5ac85c35-c512-4ed4-bef1-28118d6c7e9e' # Progressive's uuid. Don't want to accidentially mess something up.

      catalogue_message = { status: 'CAT NONE',
                            message: '' }
      rvparky_message = { status: 'RV NONE',
                          message: '' }

      if catalogue_changed.present?
        request = Typhoeus::Request.put('http://centralcatalogue.com:3200/api/v1/locations/' + uuid + '?' + catalogue_changed,
                                        headers: {'x-api-key' => '3049ae6c-1ba8-463e-a18b-c511fd7ec0b2'},
                                        :ssl_verifyhost => 0) #Server is set as verified but without proper certification.
        if request.response_code == 201
          catalogue_message[:status] = 'CAT SUCCESS'
          catalogue_message[:message] = 'Central Catalogue: Changes successfully submitted.'
        else
          catalogue_message[:status] = 'CAT ALERT'
          catalogue_message[:message] = 'Central Catalogue: There was an error submitting the changes. Please try again shortly.'
        end
      end

      if rvparky_changed.present?
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

      park.editable = old_status == park.status
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
        redirect_to marked_park_index_path
      end
    else
      # Using the session to transfer previous inputs because I have no other clue
      # how to do so.
      session[:previous_edit] = processed_inputs
      session[:previous_edit][:id] = park.id
      flash[:WARNING] = 'Field mismatch. Please double-check that all values are the same on both sides.'
      redirect_back fallback_location: root_path
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

  def validate_changes(inputs)
    result = { catalogue: {},
               rvparky: {},
               status: 'MATCH' }

    inputs.each do |key, value|
      if key.to_s.include?('Catalogue_')
        cut_string = key.to_s.remove('Catalogue_')
        result[:catalogue][cut_string.to_sym] = value
      elsif key.to_s.include?('RVParky_')
        cut_string = key.to_s.remove('RVParky_')
        result[:rvparky][cut_string.to_sym] = value
      end
    end

    # common_fields is taken from the CommonFields module.
    common_fields.each do |cat, rv|
      result[:status] = 'MISMATCH' unless result[:catalogue][cat.to_sym] == result[:rvparky][rv.to_sym]
    end

    return result
  end

  def process_catalogue(catalogue_hash, park)
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

  def process_rvparky(rvparky_hash, park)
    return 'foobar' # Once the API for updating RVParky is known, this will be filled in.
  end

  private
  def provide_title
    @title = 'Parks'
  end

  def get_catalogue_park(uuid)
    output = nil
    request = Typhoeus::Request.get('http://centralcatalogue.com:3200/api/v1/locations/' + uuid,
                                    headers: {'x-api-key' => '3049ae6c-1ba8-463e-a18b-c511fd7ec0b2'},
                                    :ssl_verifyhost => 0) #Server is set as verified but without proper certification.

    if request.response_code == 200
      temp_response = JSON.parse(request.response_body)

      output = hash_string_to_sym(temp_response)
    end

    return output
  end

  def get_rvparky_park(slug)
    output = nil
    request = Typhoeus::Request.get('https://www.rvparky.com/_ws2/Location/' + slug.to_s,
                                    :ssl_verifyhost => 0) #Server is set as verified but without proper certification.
    if request.response_code == 200
      temp_response = JSON.parse(request.response_body)

      temp = hash_string_to_sym(temp_response)
      output = temp[:location]
    end

    return output
  end
end