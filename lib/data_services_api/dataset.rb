module DataServicesApi
  # Encapsulates a single dataset from the data services API
  class Dataset
    attr_reader :service

    def initialize(json, service)
      @json = json
      @service = service
    end

    def id
      @json['@id']
    end

    def method_missing(attribute)
      respond_to_missing?(attribute) ? @json[attribute.to_s] : super
    end

    def respond_to_missing?(attribute)
      @json.key?(attribute.to_s)
    end

    def data_api
      @json['data-api']
    end

    def structure_api
      @json['structure-api']
    end

    def describe_api
      @json['describe-api']
    end

    def explain_api
      # TODO: there should be a HATEOS-style reference to this endpoint
      structure_api.gsub(/structure$/, 'explain')
    end

    def structure
      return @structure if defined?(@structure)

      description = service.api_get_json(structure_api)
      aspects = description['aspects']
      @structure = aspects.map { |json| Aspect.new(json, service) }
    end

    def query(query)
      service.api_post_json(data_api, query.to_json)
    end

    def describe(uri)
      service.api_get_json(describe_api, uri: uri)
    end

    def explain(query)
      service.api_post_json(explain_api, query.to_json)
    end
  end
end
