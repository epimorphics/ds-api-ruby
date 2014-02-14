module DataServicesApi
  # Denotes the encapsulated DataServicesAPI service
  class Service
    DEFAULT_URL = "http://localhost:8080/dsapi"

    attr_reader :url

    def initialize( config = {} )
      @url = config[:url] || DEFAULT_URL
    end

    def datasets
      get_json( url + "/dataset" ).map {|json| Dataset.new( json )}
    end

    private

    # Get parsed JSON from the given URL
    def get_json( http_url, options = {} )
      response = get_from_api( http_url, options )
      JSON.parse( response.body )
    end

    def get_from_api( http_url, options )
      conn = create_http_connection( http_url )
      set_connection_timeout( conn )

      response = conn.get do |req|
        req.headers['Accept'] = "application/json"
        req.params.merge! options
      end

      raise "Failed to read from #{http_url}: #{response.status.inspect}" unless ok?( response )
      response
    end

    def create_http_connection( http_url )
      Faraday.new( url: http_url ) do |faraday|
        faraday.request  :url_encoded
        faraday.use      FaradayMiddleware::FollowRedirects
        faraday.adapter  :net_http
        set_logger_if_rails( faraday )
      end
    end

    def set_connection_timeout( conn )
      conn.options[:timeout] = 60
    end

    def ok?( response )
      (200..207).include?( response.status )
    end

    def set_logger_if_rails( faraday )
        if defined?( Rails )
          faraday.response :logger, Rails.logger
        end
    end

  end
end
