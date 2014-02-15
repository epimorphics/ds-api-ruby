module DataServicesApi

  # Generate Data Service API queries, and serialize as JSON
  class QueryGenerator
    attr_reader :terms

    def initialize( terms = nil )
      @terms = terms || {}
    end

    def to_json
      @terms.to_json
    end

    def equals( attribute, value )
      QueryGenerator.new( @terms.merge( {attribute => {eq: value}} ))
    end
  end
end
