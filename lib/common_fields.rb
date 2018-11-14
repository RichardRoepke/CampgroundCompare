module CommonFields
  # Returns an array of string pairs, which correspond to equivalent fields in
  # CentralCatalogue and RVParky.

  def common_fields
    # review_count and rating will be checked once a way to transfer/compare
    # reviews is found.
    return [['website', 'website'],
            ['formerName', 'formerlyKnownAs'],
            #['rating', 'rating'],
            ['alternativeName', 'alsoKnownAs'],
            ['city', 'city'],
            ['longitude', 'lon'],
            ['latitude', 'lat'],
            ['postalCode', 'zip_code'],
            ['phone', 'phone_number'],
            ['description', 'description'],
            ['address', 'address'],
            ['name', 'name']]
            #['review_count', 'review_count']
  end
end