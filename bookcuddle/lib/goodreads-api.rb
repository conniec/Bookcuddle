require 'oauth'
require 'oauth/consumer'

module GoodReadsAPI
    
    def GoodReadsAPI.im_awesome
        puts "Connie2 is so awesome"
    end

    def GoodReadsAPI.cool
        puts "cool!"
    end

    def GoodReadsAPI.authorize_url
        consumer = OAuth::Consumer.new('oLeXuyhixiL1lMwTsw3fw', 
                           'Jmw8ybptcmxrxv6p0IyKeTMKSHCPZZ1DYv53bRomU', 
                           :site => 'http://www.goodreads.com')
        request_token = consumer.get_request_token
        puts request_token
        puts request_token.authorize_url
        request_token.authorize_url
    end

    def GoodReadsAPI.auth_user
        uri = URI.parse 'http://www.goodreads.com/api/auth_user'
    end

end