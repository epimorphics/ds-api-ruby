# frozen_string_literal: true

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

    def respond_to_missing?(attribute, _args = nil)
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
      # There should be a HATEOS-style reference to this endpoint
      # https://github.com/epimorphics/ds-api-ruby/issues/1
      structure_api.gsub(/structure$/, 'explain')
    end

    def structure
      return @structure if defined?(@structure)

      description = service.api_get_json(structure_api)
      aspects = description['aspects']
      @structure = aspects.map { |json| Aspect.new(json, service) }
    end

    def query(query)
      converter = SapiNTConverter.new(query.to_json)
      sapi_query = converter.to_sapint_query
      query_url = "#{data_api}?#{sapi_query}"
      sapint_response = service.api_get_json(query_url)
      converter.to_dsapi_response(sapint_response)
    end

    def describe(uri)
      service.api_get_json(describe_api, uri: uri)
    end

    def explain(query)
      # service.api_post_json(explain_api, query.to_json)
      # WAITING ON SAPITNT EXPLAIN
    end
  end
end
