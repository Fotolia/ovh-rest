require 'test_helper'

class TestApiUrl < Test::Unit::TestCase
  def test_default_api_url
    ovh = OVH::REST.new('api_key', 'api_secret', 'consumer_key')
    assert_equal ovh.api_url, 'https://api.ovh.com/1.0'
  end

  def test_api_url_change
    ca_api = 'https://ca.api.ovh.com/1.0'

    ovh = OVH::REST.new('api_key', 'api_secret', 'consumer_key', ca_api)
    assert_equal ovh.api_url, ca_api
  end
end