module API
  class Goodreads
    attr_reader :request_token, :authorize_url, :response
  
    def initialize
    end

    def authorize_url
      @authorize_url = @request_token.authorize_url
    end

    def get_request_token
      @request_token = set_consumer.get_request_token
    end
  
    def auth_user(access_token, access_token_secret)
      token = set_access_token(access_token, access_token_secret)
      @response = token.get('http://www.goodreads.com/api/auth_user')
    end
    
    def user_friends(access_token, access_token_secret, user_id)
      token = set_access_token(access_token, access_token_secret)
      @response = token.get()      
    end

    private
    def set_consumer
      OAuth::Consumer.new('oLeXuyhixiL1lMwTsw3fw', 
                          'Jmw8ybptcmxrxv6p0IyKeTMKSHCPZZ1DYv53bRomU', 
                          :site => 'http://www.goodreads.com')
    end

    private
    def set_access_token(access_token, access_token_secret)
      OAuth::AccessToken.new(set_consumer, access_token, access_token_secret)
    end


  end
end