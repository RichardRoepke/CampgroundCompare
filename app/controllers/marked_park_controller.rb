class MarkedParkController < ApplicationController
  before_action :provide_title

  def index
    @parks = MarkedPark.page(params[:page]).per(12)
  end

  def show
    @catalogue = nil
    @rvparky = nil

    park = MarkedPark.find(params[:id])

    if park.uuid.present?
      catalogue_temp = get_catalogue_park(park.uuid)
      @catalogue = CatalogueLocationValidator.new(catalogue_temp) if catalogue_temp.present?
    end

    if park.slug.present?
      rvparky_temp = get_rvparky_park(park.slug)
      @rvparky = RvparkyLocationValidator.new(rvparky_temp) if rvparky_temp.present?
    end

    if park.differences.present?
      @differences = park.differences
    end
  end

  def edit
    @catalogue = nil
    @rvparky = nil

    park = MarkedPark.find(params[:id])

    if park.uuid.present?
      catalogue_temp = get_catalogue_park(park.uuid)
      @catalogue = CatalogueLocationValidator.new(catalogue_temp) if catalogue_temp.present?
    end

    if park.slug.present?
      rvparky_temp = get_rvparky_park(park.slug)
      @rvparky = RvparkyLocationValidator.new(rvparky_temp) if rvparky_temp.present?
    end

    if park.differences.present?
      @differences = park.differences
    end
  end

  def quick
    @park = MarkedPark.find(params[:id])

    unless @park.status == 'UUID IS INVALID' || @park.status == 'SLUG IS INVALID' || @park.status == 'NO CONNECTION'
      @catalogue = nil
      @rvparky = nil

      if @park.uuid.present?
        catalogue_temp = get_catalogue_park(@park.uuid)
        @catalogue = CatalogueLocationValidator.new(catalogue_temp) if catalogue_temp.present?
      end

      if @park.slug.present?
        rvparky_temp = get_rvparky_park(@park.slug)
        @rvparky = RvparkyLocationValidator.new(rvparky_temp) if rvparky_temp.present?
      end

      if @rvparky.present? && @catalogue.present?
        @differences = @park.differences
      else
        redirect_to marked_park_path(@park), alert: 'Could not connect to the required web services.'
      end
    else
      redirect_to marked_park_path(@park), alert: 'Differences could not be determined due to asdfjkl;asdjfkas;jfkl;asdjfs;a'
    end
  end

  def submit_changes
    park = MarkedPark.find(params[:id])

    catalogue_changed = ''

    params.each do |key, value|
      if key.include?('Catalogue_')
        temp_string = key.remove('Catalogue_')
        diff = park.differences.find_by(catalogue_field: temp_string)
        unless diff.catalogue_value == value
          catalogue_changed += '%26' unless catalogue_changed.blank?
          catalogue_changed += 'location%5B' + temp_string + '%5D=' + value
        end
      elsif key.include?('RVParky_')
        # Updating RVParky information will have to wait for the future.
      end
    end

    catalogue_changed.gsub!(' ', '%20') unless catalogue_changed.blank?

    uuid = '5ac85c35-c512-4ed4-bef1-28118d6c7e9e' # Progressive's uuid. Don't want to accidentially mess something up.

    catalogue_message = ''
    rvparky_message = ''

    if catalogue_changed.present?
      request = Typhoeus::Request.put('http://centralcatalogue.com:3200/api/v1/locations/' + uuid + '?' + catalogue_changed,
                                      headers: {'x-api-key' => '3049ae6c-1ba8-463e-a18b-c511fd7ec0b2'},
                                      :ssl_verifyhost => 0) #Server is set as verified but without proper certification.
      if request.response_code == '201'
        catalogue_message = 'Changes successfully submitted.'
      else
        catalogue_message = 'There was an error submitting the changes.'
      end
    end

    flash['CAT SUCCESS'] = catalogue_message if catalogue_message.present?
    flash['RV SUCCESS'] = rvparky_message if rvparky_message.present?

    if params["commit"] == 'Submit and Next'
      target = park

      loop do
        target = target.next
        break if target.blank? || ['INFORMATION MISMATCH',
                                   'BOTH LACK INFORMATION',
                                   'RVPARKY LACKS INFORMATION',
                                   'CATALOGUE LACKS INFORMATION'].include?(target.status)
      end

      redirect_to marked_park_quick_path(target.id) if target.present?
      redirect_to marked_park_index_path, alert: 'No further parks found.' unless target.present?
    else
      redirect_to marked_park_index_path
    end
  end

  def status
    MarkedPark.find_each do |park|
      park.update_status
      park.destroy if park.status == 'DELETE ME'
      park.save if park.valid?
    end

    redirect_to marked_park_index_path, alert: 'All parks have been updated.'
  rescue => exception
    redirect_to marked_park_index_path, alert: 'An error has occurred. Please try again.'
  end

  private
  def provide_title
    @title = 'Parks'
  end

  def get_catalogue_park(uuid)
    output = nil
    request = Typhoeus::Request.get('https://centralcatalogue.com/api/v1/locations/' + uuid,
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