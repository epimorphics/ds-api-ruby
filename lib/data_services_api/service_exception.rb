# Capture exceptions when talking to remote services

module DataServicesApi
  class ServiceException < RuntimeError
    attr_reader :status, :source, :service_message

    def initialize( msg, status, source = nil, service_msg = nil )
      super( msg )

      @status = status
      @source = source
      @service_msg = service_message
    end

  end
end
