# frozen_string_literal: true

module DataServicesApi
  class DSAPIResponseConverter
    def initialize(sapint_response, dataset_name, json_mode_compact: false)
      @sapint_response = sapint_response
      @dataset_name = dataset_name
      @json_mode_compact = json_mode_compact
    end

    # Converts SAPINT returned JSON format to DSAPI returned JSON format
    def to_dsapi_response
      @sapint_response['items'].map do |value|
        to_dsapi_item(value)
      end
    end

    private

    def to_dsapi_item(sapint_item)
      sapint_item.reduce({}) do |result, (key, value)|
        result.merge(to_dsapi_json(key, value))
      end
    end

    def to_dsapi_json(sapint_key, sapint_value)
      # Return different response formats based on the set JSON mode
      return json_mode_compact(sapint_key, sapint_value) if @json_mode_compact

      json_mode_complete(sapint_key, sapint_value)
    end

      return { sapint_key => sapint_value } if sapint_key == '@id'
      return { "#{dataset_name}:#{sapint_key}" => sapint_value } unless sapint_value.is_a?(Hash)

      sapint_value.map do |key, value|
        ["#{dataset_name}:#{sapint_key}#{key == '@id' ? '' : key.capitalize}", value]
      end.to_h
    end
  end
end
