require 'test_helper'

class RvparkyLocationValidatorTest < ActiveSupport::TestCase
  def setup
    @params = { id: 5,
                website: 'test@park.com',
                formerlyKnownAs: 'Other Park',
                weeklyRateUpdated: '1111-11-11',
                rating: 2,
                dailyRate_offseason: 'temp',
                alsoKnownAs: 'Yet Another Park',
                dailyRate: '$5.5',
                category: 'None',
                city: 'Test City',
                review_count: 2,
                reservation_url: 'reservation@park.com',
                longitude: 7.7,
                latitude: 3.3,
                sites: 5,
                discounts: 'temp',
                closed: 'temp',
                zip_code: '55555',
                phone_number: '(555)-555-5555',
                open_dates: 'temp',
                seasonalRates: 'temp',
                description: 'A park for testing things.',
                offSeasonDates: 'temp',
                address: '555 Test Lane',
                slug: 'Slugger',
                inSeasonDates: 'temp',
                name: 'Test Park',
                dailyRateUpdated: '1111-11-11',
                monthlyRateUpdated: '1111-11-11',
                region: 'Texas',
                monthlyRate: '5',
                weeklyRate: '7',
                weeklyRate_offseason: 'temp',
                monthlyRate_offseason: 'temp',
                amenities: ['tst', 'pkp', 'lsl', 'opo'],
                pictures: [{ url: 'foobar',
                             thumbUrl: 'barfoo' },
                           { url: 'test',
                             thumbUrl: 'test2' },
                           { url: 'temp',
                             thumbUrl: 'temper' }],
                reviews: [{ rating: 2,
                            text: "A fine test review",
                            date_stayed_start: nil,
                            author_name: "Test Sam",
                            date_stayed_end: nil,
                            date: "2017-07-01T20:30:09.905470",
                            id: 5819889907924992,
                            author: 5231264232636416,
                            title: "Test Title",
                            comments: [],
                            location: 13570 },
                          { rating: 5,
                            text: "Another fine test review",
                            date_stayed_start: '1111-11-11',
                            author_name: "Test Bob",
                            date_stayed_end: '1111-11-11',
                            date: "2017-07-01T20:30:09.905470",
                            id: 5819889907924993,
                            author: 5231264232636415,
                            title: "Test Title",
                            comments: [],
                            location: 13570 }],
                cat: 1,
                dump_station: 1,
                pullThruSites: 1,
                electric: 1,
                waterfront: 1,
                cableTv: 0,
                wiFi: 0,
                handicap: 0}
    @validator = RvparkyLocationValidator.new(@params)
  end

  test 'validator should set up properly' do
    @validator.valid?

    assert @validator.valid?
    assert @validator.id == @params[:id]
    assert @validator.website == @params[:website]
    assert @validator.formerlyKnownAs == @params[:formerlyKnownAs]
    assert @validator.weeklyRateUpdated == @params[:weeklyRateUpdated]
    assert @validator.rating == @params[:rating]
    assert @validator.dailyRate_offseason == @params[:dailyRate_offseason]
    assert @validator.alsoKnownAs == @params[:alsoKnownAs]
    assert @validator.dailyRate == @params[:dailyRate]
    assert @validator.category == @params[:category]
    assert @validator.city == @params[:city]
    assert @validator.review_count == @params[:review_count]
    assert @validator.reservation_url == @params[:reservation_url]
    assert @validator.longitude == @params[:longitude]
    assert @validator.latitude == @params[:latitude]
    assert @validator.sites == @params[:sites]
    assert @validator.discounts == @params[:discounts]
    assert @validator.closed == @params[:closed]
    assert @validator.zip_code == @params[:zip_code]
    assert @validator.phone_number == @params[:phone_number]
    assert @validator.open_dates == @params[:open_dates]
    assert @validator.seasonalRates == @params[:seasonalRates]
    assert @validator.description == @params[:description]
    assert @validator.offSeasonDates == @params[:offSeasonDates]
    assert @validator.address == @params[:address]
    assert @validator.slug == @params[:slug]
    assert @validator.inSeasonDates == @params[:inSeasonDates]
    assert @validator.name == @params[:name]
    assert @validator.dailyRateUpdated == @params[:dailyRateUpdated]
    assert @validator.monthlyRateUpdated == @params[:monthlyRateUpdated]
    assert @validator.region == @params[:region]
    assert @validator.monthlyRate == @params[:monthlyRate]
    assert @validator.weeklyRate == @params[:weeklyRate]
    assert @validator.weeklyRate_offseason == @params[:weeklyRate_offseason]
    assert @validator.monthlyRate_offseason == @params[:monthlyRate_offseason]

    assert @validator.amenities == @params[:amenities]
  end

  test 'pictures should be processed correctly' do
    assert @validator.images.size == 3
    assert @validator.images[0].valid?
    assert @validator.images[1].valid?
    assert @validator.images[2].valid?

    assert @validator.images[0].url == @params[:pictures][0][:url]
    assert @validator.images[0].thumb == @params[:pictures][0][:thumbUrl]
  end

  test 'reviews should be processed correctly' do
    assert @validator.reviews.size == 2
    assert @validator.reviews[0].valid?
    assert @validator.reviews[1].valid?

    assert @validator.reviews[0].rating == @params[:reviews][0][:rating]
    assert @validator.reviews[0].text == @params[:reviews][0][:text]
    assert @validator.reviews[0].start == @params[:reviews][0][:date_stayed_start]
    assert @validator.reviews[0].author_name == @params[:reviews][0][:author_name]
    assert @validator.reviews[0].end == @params[:reviews][0][:date_stayed_end]
    assert @validator.reviews[0].date == @params[:reviews][0][:date]
    assert @validator.reviews[0].author == @params[:reviews][0][:author]
    assert @validator.reviews[0].title == @params[:reviews][0][:title]
    assert @validator.reviews[0].comments == @params[:reviews][0][:comments]
    assert @validator.reviews[0].location == @params[:reviews][0][:location]
    assert @validator.reviews[0].id == @params[:reviews][0][:id]
  end

  test 'attributes must be processed correctly.' do
    @positive_attributes = ['cat', 'dump_station', 'pullThruSites', 'electric', 'waterfront']
    @negative_attributes = ['cableTv', 'wiFi', 'handicap', 'longitude', 'latitude', 'id']
    @nonexistent_attributes = ['frogRain', 'peace', 'shotput']

    @positive_attributes.each do |value|
      assert @validator.attribute_present(value) == 1
    end

    @negative_attributes.each do |value|
      assert @validator.attribute_present(value) == 0
    end

    @nonexistent_attributes.each do |value|
      assert @validator.attribute_present(value) == 0
    end
  end

  test 'id must be present' do
    @validator.id = nil
    assert_not @validator.valid?
  end

  test 'location must be present' do
    @validator.id = nil
    assert_not @validator.valid?
  end

  test 'rating must be present' do
    @validator.rating = nil
    assert_not @validator.valid?
  end

  test 'category must be present' do
    @validator.category = nil
    assert_not @validator.valid?
  end

  test 'city must be present' do
    @validator.city = nil
    assert_not @validator.valid?
  end

  test 'sites must be present' do
    @validator.sites = nil
    assert_not @validator.valid?
  end

  test 'slug must be present' do
    @validator.slug = nil
    assert_not @validator.valid?
  end

  test 'name must be present' do
    @validator.name = nil
    assert_not @validator.valid?
  end

  test 'region must be present' do
    @validator.region = nil
    assert_not @validator.valid?
  end

  test 'rating must be a number' do
    @validator.rating = 'number'
    assert_not @validator.valid?

    @validator.rating = 3.3
    assert @validator.valid?
  end

  test 'longitude must be a number' do
    @validator.longitude = 'number'
    assert_not @validator.valid?

    @validator.longitude = { number: 7 }
    assert_not @validator.valid?

    @validator.longitude = [4]
    assert_not @validator.valid?

    @validator.longitude = 2
    assert @validator.valid?
  end

  test 'latitude must be a number' do
    @validator.latitude = 'number'
    assert_not @validator.valid?

    @validator.latitude = { number: 7 }
    assert_not @validator.valid?

    @validator.latitude = [4]
    assert_not @validator.valid?

    @validator.latitude = 2
    assert @validator.valid?
  end

  test 'sites must be an integer' do
    @validator.sites = 'number'
    assert_not @validator.valid?

    @validator.sites = { number: 7 }
    assert_not @validator.valid?

    @validator.sites = [4]
    assert_not @validator.valid?

    @validator.sites = 2.2
    assert_not @validator.valid?

    @validator.sites = 2
    assert @validator.valid?
  end

  test 'review_count must be an integer' do
    @validator.review_count = 'number'
    assert_not @validator.valid?

    @validator.review_count = { number: 7 }
    assert_not @validator.valid?

    @validator.review_count = [4]
    assert_not @validator.valid?

    @validator.review_count = 2.2
    assert_not @validator.valid?

    @validator.review_count = 2
    assert @validator.valid?
  end

  test 'review_count must match the number of reviews' do
    @validator.review_count = 3
    assert_not @validator.valid?
  end

  test 'long and lat must be both present or both blank' do
    @validator.longitude = nil
    @validator.latitude = nil
    assert @validator.valid?

    @validator.longitude = 2
    @validator.latitude = nil
    assert_not @validator.valid?

    @validator.longitude = nil
    @validator.latitude = 3
    assert_not @validator.valid?

    @validator.longitude = 3
    @validator.latitude = 4
    assert @validator.valid?
  end
end