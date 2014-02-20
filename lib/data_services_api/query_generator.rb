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
      relational( "@eq", attribute, value )
    end

    def ge( attribute, value )
      relational( "@ge", attribute, value )
    end

    def gt( attribute, value )
      relational( "@gt", attribute, value )
    end

    def le( attribute, value )
      relational( "@le", attribute, value )
    end

    def lt( attribute, value )
      relational( "@lt", attribute, value )
    end

    private

    def relational( rel, attribute, value )
      QueryGenerator.new( @terms.merge( {attribute => {rel => value}} ))
    end

  end
end
