module DataServicesApi
  # Encapsulates a single dataset from the data services API
  class Dataset
    def initialize( json )
      @json = json
    end

    def id
      @json["@id"]
    end
  end
end
