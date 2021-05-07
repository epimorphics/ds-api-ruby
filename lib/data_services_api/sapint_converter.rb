# frozen_string_literal: true

module DataServicesApi
  class SapiNTConverter
    def initialize(dsapi_query)
      @dsapi_query = JSON.parse(dsapi_query)
    end

    # Converts a DSAPI query to SAPINT query
    def to_sapint_query
      result = @dsapi_query.map do |key, value|
        sapint_query(key, value)
      end.compact.join('&')
      sanitize_result(result)
    end

    private

    def sapint_query(key, value)
      case key
      when '@sort'
        sort(value)
      when '@count'
        count(value)
      when '@limit'
        limit(value)
      when '@offset'
        offset(value)
      when '@and'
        andd(value)
      end
    end

    def sort(values)
      values.map do |value|
        sort_prop = value.key?('@up') ? "+#{value['@up']}" : "-#{value['@down']}"
        "_sort=#{sort_prop}"
      end
    end

    def count(value)
      '_count=@id' if value == true
    end

    def limit(value)
      "_limit=#{value}"
    end

    def offset(value)
      "_offset=#{value}"
    end

    def andd(values)
      values.map do |value|
        attribute = remove_prefix(value.keys[0])
        rel = value.values[0].keys[0]
        json = value.values[0].values[0]
        relation(rel, attribute, json)
      end
    end

    def relation(rel, attribute, json)
      case rel
      when '@eq'
        eq(attribute, json)
      when '@oneof'
        oneof(attribute, json)
      when '@ge'
        ge(attribute, json)
      when '@gt'
        gt(attribute, json)
      when '@le'
        le(attribute, json)
      when '@lt'
        lt(attribute, json)
      when '@search'
        search(attribute, json)
      end
    end

    def eq(attribute, value)
      return "#{attribute}=#{value}" unless value.is_a?(Hash)
      return "#{attribute}=#{remove_prefix(value['@id'])}" if value.key?('@id')

      "#{attribute}=#{value['@value']}"
    end

    def oneof(attribute, values)
      values.map do |value|
        eq(attribute, value)
      end
    end

    def ge(attribute, value)
      return "mineq-#{attribute}=#{value}" unless value.is_a?(Hash)

      "mineq-#{attribute}=#{value['@value']}"
    end

    def gt(attribute, value)
      return "min-#{attribute}=#{value}" unless value.is_a?(Hash)

      "min-#{attribute}=#{value['@value']}"
    end

    def le(attribute, value)
      return "maxeq-#{attribute}=#{value}" unless value.is_a?(Hash)

      "maxeq-#{attribute}=#{value['@value']}"
    end

    def lt(attribute, value)
      return "max-#{attribute}=#{value}" unless value.is_a?(Hash)

      "max-#{attribute}=#{value['@value']}"
    end

    def search(attribute, value)
      property = remove_prefix(value['@property'])
      search_text = sanitize_search(value['@value'])
      "searchPath=#{attribute}&search-#{property}=#{search_text}"
    end

    def sanitize_search(search_text)
      search_text
        .gsub(' AND ', ' ')
        .gsub('( ', '')
        .gsub(' )', '')
    end

    def remove_prefix(value)
      value.split(':')[1] unless value.slice(0...4) == 'http'
    end

    # Removes duplicate searchPaths and constructs JSON from params array
    def sanitize_result(result)
      json_result = {}
      result.split('&').each do |value|
        param = value.split('=')
        json_result[param[0]] = [] unless json_result.key?(param[0])
        json_result[param[0]].push(param[1])
      end
      json_result['searchPath'] && json_result['searchPath'] = [json_result['searchPath'].first]
      json_result
    end
  end
end
