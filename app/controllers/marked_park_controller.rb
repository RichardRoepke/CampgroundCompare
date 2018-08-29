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
    @catalogue = nil
    @rvparky = nil

    @park = MarkedPark.find(params[:id])

    if @park.uuid.present?
      catalogue_temp = get_catalogue_park(@park.uuid)
      @catalogue = CatalogueLocationValidator.new(catalogue_temp) if catalogue_temp.present?
    end

    if @park.slug.present?
      rvparky_temp = get_rvparky_park(@park.slug)
      @rvparky = RvparkyLocationValidator.new(rvparky_temp) if rvparky_temp.present?
    end

    if @rvparky.present? && @catalogue.present?
      @differences = @park.calculate_differences(@catalogue, @rvparky, true)
    else
      redirect_to marked_park_path(@park), alert: 'Could not find inforjlk;afsdjfl;kajdf;lasdkjkaf;jklasjklasjkasl;asjkl;asdfj '
    end
  end

  def submit_changes
    @park = MarkedPark.find(params[:id])

    puts '==========================================================================='
    puts params.inspect
    puts '==========================================================================='

    params.each do |key, value|
      puts key + ': ' + value if key.include?('Catalogue_')
      puts key + ': ' + value if key.include?('RVParky_')
    end

    if params["commit"] == 'Submit and Next'
      target = @park.next
      redirect_to marked_park_quick_path(target) unless target.nil?
      redirect_to marked_park_index_path, alert: 'No further parks found.'
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
    puts '========================================================================='
    puts exception.inspect
    puts '========================================================================='
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