module DataServicesApi
  class Aspect
    attr_reader :service

    def initialize( json, service )
      @json = json
      @service = service
    end

    def id
      @json["@id"]
    end

    alias :uri :id

    def method_missing( name )
      @json[name.to_s]
    end

    def optional?
      self.isOptional
    end

    def multi_valued?
      self.isMultiValued
    end

    def range_type
      self.rangeType
    end

  end
end
