module DataServicesApi

  # Generate Data Service API queries, and serialize as JSON
  class QueryGenerator
    attr_reader :terms

    def initialize( prior = nil )
      @terms = {}
    end

    def to_json
      @terms.to_json
    end
  end
end
