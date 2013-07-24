require 'digest/sha1'
require "uri"
require 'net/http'
require 'net/https'
require 'json'

module OVH

  class RESTError < StandardError; end

  class REST
    API_URL = "https://api.ovh.com/1.0"

    class << self
      def generate_consumer_key(api_key, access_rules)
        uri = URI.parse("#{API_URL}/auth/credential")
        request = Net::HTTP::Post.new(uri.path, initheader = {"X-Ovh-Application" => api_key, "Content-type" => "application/json"})
        request.body = access_rules.to_json
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        response = http.request(request)
        JSON.parse(response.body)
      end
    end

    def initialize(api_key, api_secret, consumer_key)
      @api_url = API_URL
      @api_key, @api_secret, @consumer_key = api_key, api_secret, consumer_key
    end

    [:get, :post, :put, :delete].each do |method|
      define_method method do |endpoint, payload = nil|
        raise RESTError, "Invalid endpoint #{endpoint}, should match '/<service>/.*'" unless %r{^/\w+/.*$}.match(endpoint)

        url = @api_url + endpoint
        uri = URI.parse(url)
        body = payload.to_json unless payload.nil?

        # create OVH authentication headers
        headers = build_headers(method, url, body)

        # instanciate Net::HTTP::Get, Post, Put or Delete class
        request = Net::HTTP.const_get(method.capitalize).new(uri.path, initheader = headers)
        request.body = body

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        response = http.request(request)
        result = JSON.parse(response.body)

        unless response.is_a?(Net::HTTPSuccess)
          raise RESTError, "Error querying #{endpoint}: #{result["message"]}"
        end

        result
      end
    end

    private

    def build_headers(method, url, body)
      ts = Time.now.to_i.to_s
      sig = compute_signature(method, url, body, ts)

      headers = {
        "X-Ovh-Application" => @api_key,
        "X-Ovh-Consumer" => @consumer_key,
        "X-Ovh-Timestamp" => ts,
        "X-Ovh-Signature" => sig,
        "Content-type" => "application/json"
      }
    end

    def compute_signature(method, url, body, ts)
      "$1$" + Digest::SHA1.hexdigest("#{@api_secret}+#{@consumer_key}+#{method.upcase}+#{url}+#{body}+#{ts}")
    end
  end
end
