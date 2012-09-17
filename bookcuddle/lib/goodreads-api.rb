require 'oauth'
require 'oauth/consumer'

module GoodReadsAPI

    class GoodReadsAPI
    
        def im_awesome
            puts "Connie2 is so awesome"
        end

        def cool
            puts "cool!"
        end

        def authorize_url
            consumer = OAuth::Consumer.new('oLeXuyhixiL1lMwTsw3fw', 
                               'Jmw8ybptcmxrxv6p0IyKeTMKSHCPZZ1DYv53bRomU', 
                               :site => 'http://www.goodreads.com')
            request_token = consumer.get_request_token
            puts request_token
            puts request_token.authorize_url
            request_token.authorize_url
        end

        def auth_user
            uri = URI.parse 'http://www.goodreads.com/api/auth_user'
        end
    end


end