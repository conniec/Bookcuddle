module API
  class Goodreads
    attr_reader :request_token, :authorize_url, :response
  
    def initialize(access_token = nil, access_token_secret = nil)
      @access_token = access_token
      @access_token_secret = access_token_secret
    end

    def authorize_url
      @authorize_url = @request_token.authorize_url
    end

    def get_request_token
      @request_token = set_consumer.get_request_token
    end
    
    def get_auth_user_goodreads(access_token, access_token_secret)
      res = auth_user(access_token, access_token_secret)
      doc = Nokogiri::XML(res)

      goodreads_id = doc.at_xpath("//GoodreadsResponse//user").attr('id')
      goodreads_name = doc.at_xpath("//GoodreadsResponse//name").content

      goodreads_values = {:goodreads_id => goodreads_id, :goodreads_name => goodreads_name}
      #user = User.get_or_create_goodreads_user(goodreads_id, goodreads_name)
    end
    
    def get_user_friends(user_id)
      res = user_friends(user_id)
      doc = Nokogiri::XML(res)
      
      friends = doc.xpath("//friends//user")
      
      friends_info = []
      
      friends.each do |friend|
        info = friend.children
        friends_info << { :name => info.at_css('name').content,
                          :goodreads_id => info.at_css('id').content,
                          :photo_url => info.at_css('small_image_url').content
                        }
      end
      
      friends_info
    end

    def compare_users(goodreads_id)
      token = set_access_token(@access_token, @access_token_secret)
      response = token.get("http://www.goodreads.com/user/compare/#{ goodreads_id }.xml")
      response.body
    end

    # def get_user_status_updates(access_token, access_token_secret, goodreads_id)
    #   user = user_info(access_token, access_token_secret, goodreads_id)
    #   doc = Nokogiri::XML(user)
    #   
    #   status_updates = 
    #   
    #   connie.at_xpath("//updates//update[@type='userstatus']//action_text").content
    # end

    private
      def set_consumer
        OAuth::Consumer.new('oLeXuyhixiL1lMwTsw3fw', 
                            'Jmw8ybptcmxrxv6p0IyKeTMKSHCPZZ1DYv53bRomU', 
                            :site => 'http://www.goodreads.com')
      end
    
      def set_access_token(access_token, access_token_secret)
        OAuth::AccessToken.new(set_consumer, access_token, access_token_secret)
      end
      
      def auth_user(access_token, access_token_secret)
        token = set_access_token(access_token, access_token_secret)
        response = token.get('http://www.goodreads.com/api/auth_user')
        response.body
      end
      
      
      def user_info(goodreads_id)
        token = set_access_token(@access_token, @access_token_secret)
        response = token.get("http://www.goodreads.com/user/show/#{ goodreads_id }.xml", { 
                     'key' => 'oLeXuyhixiL1lMwTsw3fw', 
                   })
        response.body
      end
      
      def user_friends(user_id)
        token = set_access_token(@access_token, @access_token_secret)
        response = token.get("http://www.goodreads.com/friend/user/#{ user_id }?format=xml")
        response.body
      end
  end
end