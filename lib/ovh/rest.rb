require 'digest/sha1'
require "uri"
require 'net/http'
require 'net/https'
require 'json'

module OVH

  class RESTError < StandardError; end

  class REST
    DEFAULT_API_URL = "https://api.ovh.com/1.0"

    attr_accessor :api_url

    class << self
      def generate_consumer_key(api_key, access_rules, api_url = nil)
        uri = URI.parse("#{api_url || DEFAULT_API_URL}/auth/credential")
        request = Net::HTTP::Post.new(uri.path, initheader = {"X-Ovh-Application" => api_key, "Content-type" => "application/json"})
        request.body = access_rules.to_json
        http = build_http_object(uri.host, uri.port)
        http.use_ssl = true
        response = http.request(request)
        JSON.parse(response.body)
      end

      def build_http_object(host, port)
        if ENV['https_proxy']
          proxy = URI.parse(ENV['https_proxy'])
          Net::HTTP::Proxy(proxy.host, proxy.port).new(host, port)
        else
          Net::HTTP.new(host, port)
        end
      end
    end

    def initialize(api_key, api_secret, consumer_key, api_url = nil)
      @api_url = api_url || DEFAULT_API_URL
      @api_key, @api_secret, @consumer_key = api_key, api_secret, consumer_key
    end

    [:get, :post, :put, :delete].each do |method|
      define_method method do |endpoint, payload = nil|
        raise RESTError, "Invalid endpoint #{endpoint}, should match '/<service>/.*'" unless %r{^/\w+/.*$}.match(endpoint)

        url = @api_url + endpoint
        uri = URI.parse(url)
        body = nil

        # encode payload accordingly
        if payload
          method == :get ? uri.query = URI.encode_www_form(payload) : body = payload.to_json
        end

        # create OVH authentication headers
        headers = build_headers(method, uri.to_s, body)

        # instanciate Net::HTTP::Get, Post, Put or Delete class
        request_uri = uri.path
        request_uri += '?' + uri.query if uri.query
        request = Net::HTTP.const_get(method.capitalize).new(request_uri, initheader = headers)
        request.body = body

        http = REST.build_http_object(uri.host, uri.port)
        http.use_ssl = true
        response = http.request(request)
        result = response.body == "null" ? nil : JSON.parse(response.body)

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
