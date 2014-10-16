module DataServicesApi
  # Denotes the encapsulated DataServicesAPI service
  class Service
    DEFAULT_URL = "http://localhost:8080/dsapi"

    attr_reader :url

    def initialize( config = {} )
      @url = config[:url] || DEFAULT_URL
    end

    def datasets
      api_get_json( "/dataset" ).map {|json| Dataset.new( json, self )}
    end

    def dataset( name )
      raise "Dataset name is required" unless name
      json = api_get_json( "/dataset/#{name}" )
      json && Dataset.new( json, self )
    end

    def api_get_json( api, options = {} )
      get_json( as_http_api( api ), options )
    end

    def api_post_json( api, json )
      post_json( as_http_api( api ), json )
    end

    private

    # Get parsed JSON from the given URL
    def get_json( http_url, options )
      log_if_rails "Getting JSON URL #{http_url}"
      result = nil

      Yajl::HttpStream.get( http_url, options ) do |json_hash|
        if result
          result = [result] unless result.is_a?( Array )
          result << json_hash
          log_if_rails "second or later result"
        else
          result = json_hash
          log_if_rails "first result"
        end
      end

      log_if_rails "Got JSON result.class = #{result.class.name} #{result.respond_to?( :size ) ? result.size : -1}"
      result
    end

    def post_json( http_url, json )
      log_if_rails "Posting JSON URL #{http_url}"
      result = nil

      options = {"Content-Type" => "application/json"}
      Yajl::HttpStream.post( http_url, json, options ) do |json_hash|
        if result
          result = [result] unless result.is_a?( Array )
          result << json_hash
          log_if_rails "second or later result"
        else
          result = json_hash
          log_if_rails "first result"
        end
      end

      log_if_rails "Post got JSON result.class = #{result.class.name} #{result.respond_to?( :size ) ? result.size : -1}"
      result
    end

    def log_if_rails( msg )
        Rails.logger.debug( msg ) if defined?( Rails ) #&& Rails.env.development?
    end

    def as_http_api( api )
      api.start_with?( "http:" ) ? api : "#{url}#{api}"
    end

  end
end
