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

    def structure
      unless @structure
        description = service.api_get_json( structure_api )
        aspects = description["aspects"]
        @structure = aspects.map {|json| Aspect.new( json, service )}
      end
    end
  end
end
