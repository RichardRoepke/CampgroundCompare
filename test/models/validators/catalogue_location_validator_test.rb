require 'test_helper'

class CatalogueLocationValidatorTest < ActiveSupport::TestCase
  def setup
    @params = { uuid: 'Whoops',
                type: 'Campground',
                name: 'Test Campground',
                bounceCode: 'Code',
                address: '555 Test Street',
                city: 'Test City',
                postalCode: '55555',
                stateName: 'Kansas',
                stateCode: 'KA',
                countryName: 'USA',
                countryCode: 'US',
                phone: '555-555-5555',
                email: 'test@testing.com',
                website: 'test@testing.web',
                latitude: 3.3,
                longitude: 7.7,
                description: 'No description',
                descriptionShort: 'None.',
                directions: 'Absolutely none.',
                alternativeName: 'None',
                formerName: 'None',
                rating: 2.5,
                amenities: [{ name: "Water",
                              group: "Facility",
                              id: 73 },
                            { name: "Electric",
                              group: "Facility",
                              id: 74,
                              token: 'Exists',
                              description: 'Electrical Power.' }],
                cobrands: [{ id: 7,
                             name: 'Test Cobrand' },
                           { id: 4,
                             name: 'Other Cobrand',
                             nameShort: 'Other',
                             code: 'no',
                             notes: 'Many',
                             description: 'A test cobrand.' }],
                images: [{ id: 7,
                           alt: 'alternative',
                           title: 'Image Title',
                           caption: 'No' },
                         { id: 8,
                           alt: 'Standard',
                           title: 'Title',
                           caption: 'Yes' }],
                memberships: [{ name: 'Tester',
                                type: 'AFFILIATE' },
                              { name: 'None',
                                type: 'MEMBER ORGANIZATION' }],
                nearbies: [{ name: 'Nothing' },
                           { name: 'Tester',
                             address: '4 Test Street',
                             city: 'Test City',
                             state: 'Kansas',
                             latitude: '1',
                             longitude: '2',
                             email: 'test@test.org',
                             phone: '555-555-5555',
                             website: 'test@test.com' }],
                paymentOptions: [{ name: 'Deposit',
                                   abbreviation: 'dep' },
                                 { name: 'Nightly',
                                   abbreviation: 'ni' }],
                rates: [{ seasonTypeName: 'Off Season',
                          seasonStart: '1111-11-11',
                          seasonEnd: '1111-11-11',
                          minRate: 4.4,
                          maxRate: 7.7,
                          personsIncluded: 3 },
                        { seasonTypeName: 'On Season',
                          seasonStart: '1111-11-11',
                          seasonEnd: '1111-11-11',
                          minRate: 5.5,
                          maxRate: 8.8,
                          personsIncluded: 5 }],
                reviews: [{ username: 'Tester',
                            rating: 2,
                            body: 'An absolutely terrible test review.',
                            title: 'Review',
                            createdOn: '1111-11-11',
                            underReview: true,
                            location: 77 },
                          { username: 'Test User',
                            rating: 5,
                            body: 'A fine test review.',
                            title: 'Test',
                            createdOn: '1111-11-11',
                            arrival: '1111-11-11',
                            departure: '1111-11-11',
                            underReview: true,
                            location: 4 }],
                tags: [{ id: 7,
                         name: 'Tester',
                         description: 'A test tag.' },
                       { id: 7,
                         name: 'Tester',
                         description: 'A test tag.' }] }
    @validator = CatalogueLocationValidator.new(@params)
  end

  test 'validator should set up properly' do
    @validator.valid?

    assert @validator.valid?
    assert @validator.uuid == @params[:uuid]
    assert @validator.type == @params[:type]
    assert @validator.name == @params[:name]
    assert @validator.bounce == @params[:bounceCode]
    assert @validator.address == @params[:address]
    assert @validator.city == @params[:city]
    assert @validator.postal == @params[:postalCode]
    assert @validator.state == @params[:stateName]
    assert @validator.state_code == @params[:stateCode]
    assert @validator.country == @params[:countryName]
    assert @validator.country_code == @params[:countryCode]
    assert @validator.phone == @params[:phone]
    assert @validator.email == @params[:email]
    assert @validator.website == @params[:website]
    assert @validator.latitude == @params[:latitude]
    assert @validator.longitude == @params[:longitude]
    assert @validator.description == @params[:description]
    assert @validator.description_short == @params[:descriptionShort]
    assert @validator.directions == @params[:directions]
    assert @validator.alt_name == @params[:alternativeName]
    assert @validator.former_name == @params[:formerName]
    assert @validator.rating == @params[:rating]
  end

  test 'amenities should be processed correctly' do
    assert @validator.amenities.size == 2
    assert @validator.amenities[0].valid?
    assert @validator.amenities[1].valid?
    assert @validator.amenities[0].name == @params[:amenities][0][:name]
    assert @validator.amenities[0].group == @params[:amenities][0][:group]
    assert @validator.amenities[0].id == @params[:amenities][0][:id]
  end

  test 'cobrands should be processed correctly' do
    assert @validator.cobrands.size == 2
    assert @validator.cobrands[0].valid?
    assert @validator.cobrands[1].valid?
    assert @validator.cobrands[0].id == @params[:cobrands][0][:id]
    assert @validator.cobrands[0].name == @params[:cobrands][0][:name]
  end

  test 'images should be processed correctly' do
    assert @validator.images.size == 2
    assert @validator.images[0].valid?
    assert @validator.images[1].valid?
    assert @validator.images[0].id == @params[:images][0][:id]
    assert @validator.images[0].alt == @params[:images][0][:alt]
    assert @validator.images[0].title == @params[:images][0][:title]
    assert @validator.images[0].caption == @params[:images][0][:caption]
  end

  test 'memberships should be processed correctly' do
    assert @validator.memberships.size == 2
    assert @validator.memberships[0].valid?
    assert @validator.memberships[1].valid?
    assert @validator.memberships[0].name == @params[:memberships][0][:name]
    assert @validator.memberships[0].type == @params[:memberships][0][:type]
  end

  test 'nearbies should be processed correctly' do
    assert @validator.nearbies.size == 2
    assert @validator.nearbies[0].valid?
    assert @validator.nearbies[1].valid?
    assert @validator.nearbies[0].name == @params[:nearbies][0][:name]
  end

  test 'payments should be processed correctly' do
    assert @validator.payments.size == 2
    assert @validator.payments[0].valid?
    assert @validator.payments[1].valid?
    assert @validator.payments[0].name == @params[:paymentOptions][0][:name]
    assert @validator.payments[0].abbreviation == @params[:paymentOptions][0][:abbreviation]
  end

  test 'rates should be processed correctly' do
    assert @validator.rates.size == 2
    assert @validator.rates[0].valid?
    assert @validator.rates[1].valid?
    assert @validator.rates[0].name == @params[:rates][0][:seasonTypeName]
    assert @validator.rates[0].start == @params[:rates][0][:seasonStart]
    assert @validator.rates[0].end == @params[:rates][0][:seasonEnd]
    assert @validator.rates[0].min_rate == @params[:rates][0][:minRate]
    assert @validator.rates[0].max_rate == @params[:rates][0][:maxRate]
    assert @validator.rates[0].persons == @params[:rates][0][:personsIncluded]
  end

  test 'reviews should be processed correctly' do
    assert @validator.reviews.size == 2
    assert @validator.reviews[0].valid?
    assert @validator.reviews[1].valid?
    assert @validator.reviews[0].username == @params[:reviews][0][:username]
    assert @validator.reviews[0].rating == @params[:reviews][0][:rating]
    assert @validator.reviews[0].body == @params[:reviews][0][:body]
    assert @validator.reviews[0].title == @params[:reviews][0][:title]
    assert @validator.reviews[0].created == @params[:reviews][0][:createdOn]
    assert @validator.reviews[0].reviewed == @params[:reviews][0][:underReview]
    assert @validator.reviews[0].location == @params[:reviews][0][:location]
  end

  test 'tags should be processed correctly' do
    assert @validator.tags.size == 2
    assert @validator.tags[0].valid?
    assert @validator.tags[1].valid?
    assert @validator.tags[0].id == @params[:tags][0][:id]
    assert @validator.tags[0].name == @params[:tags][0][:name]
    assert @validator.tags[0].description == @params[:tags][0][:description]
  end

  test 'minimum inputs validates properly' do
    @params = { uuid: 'Whoops',
                type: 'Campground',
                name: 'Test Campground',
                address: '555 Test Street',
                city: 'Test City',
                stateName: 'Kansas',
                stateCode: 'KA',
                countryName: 'USA',
                countryCode: 'US' }
    @validator = CatalogueLocationValidator.new(@params)

    assert @validator.valid?
  end

  test 'uuid must be present' do
    @validator.uuid = nil
    assert_not @validator.valid?
  end

  test 'type must be present' do
    @validator.type = nil
    assert_not @validator.valid?
  end

  test 'name must be present' do
    @validator.name = nil
    assert_not @validator.valid?
  end

  test 'address must be present' do
    @validator.address = nil
    assert_not @validator.valid?
  end

  test 'city must be present' do
    @validator.city = nil
    assert_not @validator.valid?
  end

  test 'state must be present' do
    @validator.state = nil
    assert_not @validator.valid?
  end

  test 'state code must be present' do
    @validator.state_code = nil
    assert_not @validator.valid?
  end

  test 'country must be present' do
    @validator.country = nil
    assert_not @validator.valid?
  end

  test 'country code must be present' do
    @validator.country_code = nil
    assert_not @validator.valid?
  end

  test 'check_validator_array processes errors correctly' do
    @validator.amenities[0].name = nil
    assert_not @validator.valid?
    assert @validator.errors.full_messages == ["Name can't be blank"]
  end
end
