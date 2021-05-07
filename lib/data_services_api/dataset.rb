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
      sapi_query_params = converter.to_sapint_query
      sapint_response = service.api_get_json(data_api, sapi_query_params)
      to_dsapi_response(sapint_response)
    end

    def describe(uri)
      service.api_get_json(describe_api, uri: uri)
    end

    def explain(query)
      converter = SapiNTConverter.new(query.to_json)
      sapi_query_params = converter.to_sapint_query
      explain_url = "#{data_api}/explain"
      { sparql: service.api_get_text(explain_url, sapi_query_params) }
    end

    private

    # Converts SAPINT returned JSON format to DSAPI returned JSON format
    def to_dsapi_response(sapint_response)
      sapint_response['items'].map do |value|
        to_dsapi_item(value)
      end
    end

    def to_dsapi_item(sapint_item)
      dsapi_item = {}

      sapint_item.each do |key, value|
        dsapi_json = to_dsapi_json(key, value)
        dsapi_item.merge!(dsapi_json)
      end

      dsapi_item
    end

    def to_dsapi_json(sapint_key, sapint_value)
      dataset_name = data_api.split('/').slice(-1)

      return { sapint_key => sapint_value } if sapint_key == '@id'
      return { "#{dataset_name}:#{sapint_key}" => sapint_value } unless sapint_value.is_a?(Hash)

      dsapi_json = {}
      sapint_value.each do |key, value|
        dsapi_json["#{dataset_name}:#{sapint_key}#{key == '@id' ? '' : key.capitalize}"] = value
      end
      dsapi_json
    end
  end
end
