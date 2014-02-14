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
  end
end
