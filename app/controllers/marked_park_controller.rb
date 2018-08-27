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
  end

  def edit
    @catalogue = nil
    @rvparky = nil

    park = MarkedPark.find(params[:id])

    if park.uuid.present? && park.slug.present?
      catalogue_temp = get_catalogue_park(park.uuid)
      @catalogue = CatalogueLocationValidator.new(catalogue_temp) if catalogue_temp.present?
    end

    if park.slug.present?
      rvparky_temp = get_rvparky_park(park.slug)
      @rvparky = RvparkyLocationValidator.new(rvparky_temp) if rvparky_temp.present?
    end

    if @rvparky.present? && @catalogue.present?
      @differences = park.calculate_differences(@catalogue, @rvparky, true)
      @differences[:differences].each do |diff|
        puts diff.inspect
      end
    end
  end

  def quick
    @catalogue = nil
    @rvparky = nil

    park = MarkedPark.find(params[:id])

    if park.uuid.present? && park.slug.present?
      catalogue_temp = get_catalogue_park(park.uuid)
      @catalogue = CatalogueLocationValidator.new(catalogue_temp) if catalogue_temp.present?
    end

    if park.slug.present?
      rvparky_temp = get_rvparky_park(park.slug)
      @rvparky = RvparkyLocationValidator.new(rvparky_temp) if rvparky_temp.present?
    end

    if @rvparky.present? && @catalogue.present?
      @differences = park.calculate_differences(@catalogue, @rvparky, true)
      @differences[:differences].each do |diff|
        puts diff.inspect
      end
    end
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