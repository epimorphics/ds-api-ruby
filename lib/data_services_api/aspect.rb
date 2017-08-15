module DataServicesApi
  # Encapsulates a DSAPI Aspect
  # TODO say more here!
  class Aspect
    attr_reader :service

    def initialize(json, service)
      @json = json
      @service = service
    end

    def id
      @json['@id']
    end

    alias uri id

    def method_missing(name)
      respond_to_missing?(name) ? @json[name.to_s] : super
    end

    def respond_to_missing?(name)
      @json.key?(name.to_s)
    end

    def optional?
      isOptional
    end

    def multi_valued?
      isMultiValued
    end

    def range_type
      rangeType
    end
  end
end
