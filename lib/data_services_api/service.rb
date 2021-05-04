# frozen_string_literal: true

module DataServicesApi
  # Denotes the encapsulated DataServicesAPI service
  class Service
    DEFAULT_URL = 'http://localhost:8080'

    attr_reader :url

    def initialize(config = {})
      @url = config[:url] || DEFAULT_URL
    end

    def datasets
      api_get_json('/dataset').map { |json| Dataset.new(json, self) }
    end

    def dataset(name)
      raise 'Dataset name is required' unless name

      json = api_get_json("/dataset/#{name}")
      json && Dataset.new(json, self)
    end

    def api_get_json(api, options = {})
      get_json(as_http_api(api), options)
    end

    def api_post_json(api, json)
      post_json(as_http_api(api), json)
    end

    private

    # Get parsed JSON from the given URL
    def get_json(http_url, options)
      response = get_from_api(http_url, options)
      parse_json(response.body)
    end

    def get_from_api(http_url, options)
      conn = set_connection_timeout(create_http_connection(http_url))

      response = conn.get do |req|
        req.headers['Accept'] = 'application/json'
        req.params.merge! options
      end

      ok?(response, http_url) && response
    end

    # Parse the given JSON string into a data structure. Throws an exception if
    # parsing fails
    def parse_json(json) # rubocop:disable Metrics/MethodLength
      result = nil

      json_hash = parser.parse(StringIO.new(json)) do |json_chunk|
        if result
          result = [result] unless result.is_a?(Array)
          result << json_chunk
        else
          result = json_chunk
        end
      end

      report_json_failure(json) unless result || json_hash
      result || json_hash
    end

    def post_json(http_url, json)
      response = post_to_api(http_url, json)
      parse_json(response.body)
    end

    def post_to_api(http_url, json)
      conn = set_connection_timeout(create_http_connection(http_url))

      response = conn.post do |req|
        req.headers['Accept'] = 'application/json'
        req.headers['Content-Type'] = 'application/json'
        req.body = json
      end

      ok?(response, http_url) && response
    end

    def create_http_connection(http_url)
      Faraday.new(url: http_url) do |faraday|
        faraday.request  :url_encoded
        faraday.use      FaradayMiddleware::FollowRedirects

        if defined?(Rails) && Rails.respond_to?(:env) && Rails.env.development?
          faraday.response :logger, Rails.logger
        end

        # setting the adapter must be the final step, otherwise get a warning from Faraday
        faraday.adapter  :net_http
      end
    end

    def set_connection_timeout(conn) # rubocop:disable Naming/AccessorMethodName
      conn.options[:timeout] = 600
      conn
    end

    def ok?(response, http_url)
      unless (200..207).cover?(response.status)
        msg = "Failed to read from #{http_url}: #{response.status.inspect}"
        raise ServiceException.new(msg, response.status, http_url, response.body)
      end

      true
    end

    def as_http_api(api)
      api.start_with?('http:') ? api : "#{url}#{api}"
    end

    protected

    def parser
      @parser ||= Yajl::Parser.new
    end

    def report_json_failure(json)
      if defined?(Rails)
        msg = 'JSON result was not parsed correctly (no temp file saved)'
        Rails.logger.info(msg)
        throw msg
      else
        throw 'JSON result was not parsed correctly: ' + json.slice(0, 1000)
      end
    end
  end
end
