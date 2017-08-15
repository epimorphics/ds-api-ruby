module DataServicesApi
  # Encapsulates a single value coming back from the API
  class Value < Hash
    def initialize(base = {}, adds = {})
      merge!(base)
        .merge!(adds)
      freeze
    end

    def value
      self[:"@value"]
    end

    def type
      self[:"@type"]
    end

    def uri
      self[:"@id"]
    end

    def with_uri(uri)
      Value.new(self, :"@id" => uri)
    end

    def self.uri(uri)
      Value.new.with_uri(uri)
    end

    def with_typed_value(value, type)
      Value.new(self, :"@value" => value, :"@type" => type)
    end

    def with_year_month(year, month)
      with_typed_value(format('%04d-%02d', year.to_i, month.to_i),
                       'http://www.w3.org/2001/XMLSchema#gYearMonth')
    end

    def self.year_month(year, month)
      Value.new.with_year_month(year, month)
    end
  end
end
