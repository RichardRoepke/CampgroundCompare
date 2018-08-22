class MarkedParkController < ApplicationController
  before_action :provide_title

  def index
    @parks = MarkedPark.page(params[:page]).per(12)
  end

  def show
    park = MarkedPark.find(params[:id])
    @park = CatalogueLocationValidator.new(get_individual_park(park.uuid))
  end

  private
  def provide_title
    @title = 'Parks'
  end

  def get_individual_park(uuid)
    request = Typhoeus::Request.get('https://centralcatalogue.com/api/v1/locations/' + uuid,
                                    headers: {'x-api-key' => '3049ae6c-1ba8-463e-a18b-c511fd7ec0b2'},
                                    :ssl_verifyhost => 0) #Server is set as verified but without proper certification.

    temp_response = JSON.parse(request.response_body)

    return hash_string_to_sym(temp_response)
  end
end