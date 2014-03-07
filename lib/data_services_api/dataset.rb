module DataServicesApi
  # Encapsulates a single dataset from the data services API
  class Dataset
    attr_reader :service

    def initialize( json, service )
      @json = json
      @service = service
    end

    def id
      @json["@id"]
    end

    def method_missing( attribute )
      @json[attribute.to_s]
    end

    def data_api
      @json["data-api"]
    end

    def structure_api
      @json["structure-api"]
    end

    def describe_api
      # TODO there should be a HATEOS-style reference to this endpoint
      structure_api.gsub( /structure$/, "describe" )
    end

    def structure
      unless @structure
        description = service.api_get_json( structure_api )
        aspects = description["aspects"]
        @structure = aspects.map {|json| Aspect.new( json, service )}
      end
    end

    def query( query )
      service.api_post_json( data_api, query.to_json )
    end

    def describe( uri )
      service.api_get_json( describe_api, {uri: uri} )
    end
  end
end
