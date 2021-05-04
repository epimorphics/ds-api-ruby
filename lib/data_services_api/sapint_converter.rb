# frozen_string_literal: true

module DataServicesApi
  class SapiNTConverter
    SANITIZE_SEARCH = lambda { |search_text|
      search_text
        .gsub(' AND ', ' ')
        .gsub('( ', '')
        .gsub(' )', '')
    }

    REMOVE_PREFIX = lambda { |value|
      value.split(':')[1] unless value.slice(0...4) == 'http'
    }

    VALUE_FILTERS = {
      '@eq' => lambda { |attribute, value|
        return "#{attribute}=#{value}" unless value.is_a?(Hash)
        return "#{attribute}=#{REMOVE_PREFIX.call(value['@id'])}" if value.key?('@id')

        "#{attribute}=#{value['@value']}"
      },
      '@oneof' => lambda { |attribute, values|
        result = ''
        values.each do |value|
          result += "#{VALUE_FILTERS['@eq'].call(attribute, value)}&"
        end
        result.slice(0...-1)
      },
      '@ge' => lambda { |attribute, value|
        return "mineq-#{attribute}=#{value}" unless value.is_a?(Hash)

        "mineq-#{attribute}=#{value['@value']}"
      },
      '@gt' => lambda { |attribute, value|
        return "min-#{attribute}=#{value}" unless value.is_a?(Hash)

        "min-#{attribute}=#{value['@value']}"
      },
      '@le' => lambda { |attribute, value|
        return "maxeq-#{attribute}=#{value}" unless value.is_a?(Hash)

        "maxeq-#{attribute}=#{value['@value']}"
      },
      '@lt' => lambda { |attribute, value|
        return "max-#{attribute}=#{value}" unless value.is_a?(Hash)

        "max-#{attribute}=#{value['@value']}"
      },
      '@search' => lambda { |attribute, value|
        property = REMOVE_PREFIX.call(value['@property'])
        search_text = SANITIZE_SEARCH.call(value['@value'])
        "searchPath=#{attribute}&search-#{property}=#{search_text}"
      },
      '@sort' => lambda { |values|
        result = ''
        values.each do |value|
          sort_prop = value.key?('@up') ? "+#{value['@up']}" : "-#{value['@down']}"
          result += "_sort=#{sort_prop}&"
        end
        result.slice(0...-1)
      },
      '@count' => lambda { |value|
        '_count=@id' if value == true
      },
      '@limit' => lambda { |value|
        "_limit=#{value}"
      },
      '@offset' => lambda { |value|
        "_offset=#{value}"
      },
      '@and' => lambda { |values|
        result = ''
        values.each do |value|
          attribute = REMOVE_PREFIX.call(value.keys[0])
          relation = value.values[0].keys[0]
          json = value.values[0].values[0]
          result += "#{VALUE_FILTERS[relation].call(attribute, json)}&"
        end
        result.slice(0...-1)
      }
    }.freeze

    def initialize(dsapi_query)
      @dsapi_query = JSON.parse(dsapi_query)
    end

    # Converts a DSAPI query to SAPINT query
    def to_sapint_query
      sapint_query = ''
      @dsapi_query.each do |key, value|
        sapint_query += "#{VALUE_FILTERS[key].call(value)}&" if VALUE_FILTERS.key?(key)
      end
      sapint_query.slice(0...-1)
    end

    # Converts SAPINT returned JSON format to DSAPI returned JSON format
    def to_dsapi_response(sapint_response)
      dsapi_response = []

      sapint_response['items'].each do |value|
        dsapi_item = to_dsapi_item(value)
        dsapi_response.push(dsapi_item)
      end

      dsapi_response
    end

    private

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
