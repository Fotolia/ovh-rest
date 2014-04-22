require 'test_helper'

class TestApiUrl < Test::Unit::TestCase
  def setup
    @ovh = OVH::REST.new('api_key', 'api_secret', 'consumer_key')
  end

  def test_default_api_url
    assert_equal @ovh.api_url, 'https://api.ovh.com/1.0'
  end

  def test_api_url_change
    ca_api = 'https://ca.api.ovh.com/1.0'

    @ovh.api_url = 'https://ca.api.ovh.com/1.0'
    assert_equal @ovh.api_url, ca_api
  end
end