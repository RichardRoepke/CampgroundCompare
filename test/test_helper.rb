ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!


class ActiveSupport::TestCase
  include Devise::Test::IntegrationHelpers

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # generates a random string between min and (min + range) characters
  def generate_random_string(min, range = 0)
    return (0...min).map { (65 + rand(26)).chr }.join if range == 0
    return (0...(min + rand(range + 1))).map { (65 + rand(26)).chr }.join
  end
end
