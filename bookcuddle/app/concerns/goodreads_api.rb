module API
  class Goodreads
    attr_reader :request_token, :authorize_url
  
    def initialize()
      @consumer = set_consumer
      @request_token = @consumer.get_request_token
      @authorize_url = @request_token.authorize_url
    end
  
    private
    def set_consumer
      OAuth::Consumer.new('oLeXuyhixiL1lMwTsw3fw', 
                          'Jmw8ybptcmxrxv6p0IyKeTMKSHCPZZ1DYv53bRomU', 
                          :site => 'http://www.goodreads.com')
    end
  end
end