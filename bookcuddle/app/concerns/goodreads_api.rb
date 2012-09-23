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

      return {} if res[:code] != '200'

      doc = Nokogiri::XML(res[:data])

      goodreads_id = doc.at_xpath("//GoodreadsResponse//user").attr('id')
      goodreads_name = doc.at_xpath("//GoodreadsResponse//name").content

      {:goodreads_id => goodreads_id, :goodreads_name => goodreads_name}
    end
    
    def get_user_friends(user_id)
      res = user_friends(user_id)

      puts res[:code] == '200'
      friends_info = []
      return friends_info if res[:code] != '200'

      puts 'get here?'
      doc = Nokogiri::XML(res[:data])
      friends = doc.xpath("//friends//user")
      
      friends.each do |friend|
        info = friend.children
        friends_info << { :name => info.at_css('name').content,
                          :goodreads_id => info.at_css('id').content,
                          :photo_url => info.at_css('small_image_url').content
                        }
      end
      friends_info
    end
    
    def get_unread_books(goodreads_id)
      res = compare_users(goodreads_id)
      doc = Nokogiri::XML(res[:data])
      
      books = doc.xpath("//reviews//review")

      unread_books = []
      
      books.each do |book|
        puts book.css('your_review rating').text
        if book.css('your_review rating').text == 'to-read' && book.css('their_review rating').text == 'to-read'
          unread_books << { :title => book.css('book title').text,
                            :id => book.css('book id').text,
                            :url => book.css('book url').text
                          }
        end
      end
      
      unread_books
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
        OAuth::Consumer.new(APP_CONFIG['goodreads_key'],
                            APP_CONFIG['goodreads_secret'],
                            :site => 'http://www.goodreads.com')
        #OAuth::Consumer.new('oLeXuyhixiL1lMwTsw3fw', 
                            #'Jmw8ybptcmxrxv6p0IyKeTMKSHCPZZ1DYv53bRomU', 
                            #:site => 'http://www.goodreads.com')
      end
    
      def set_access_token(access_token, access_token_secret)
        OAuth::AccessToken.new(set_consumer, access_token, access_token_secret)
      end
      
      def auth_user(access_token, access_token_secret)
        token = set_access_token(access_token, access_token_secret)
        response = token.get('http://www.goodreads.com/api/auth_user')
        
        data = ''
        if response.code == '200'
          data = response.body
        end
        {:code => response.code, :data => response.body}
      end
      
      def user_info(goodreads_id)
        token = set_access_token(@access_token, @access_token_secret)
        response = token.get("http://www.goodreads.com/user/show/#{ goodreads_id }.xml", { 
                     'key' => APP_CONFIG['goodreads_key'], 
                   })

        data = ''
        if response.code == '200'
          data = response.body
        end
        {:code => response.code, :data => response.body}
      end
      
      def user_friends(user_id)
        token = set_access_token(@access_token, @access_token_secret)
        response = token.get("http://www.goodreads.com/friend/user/#{ user_id }?format=xml")

        puts 'code is: '
        puts response.code
        data = ''
        if response.code == '200'
          data = response.body
        end
        {:code => response.code, :data => response.body}
      end

      def compare_users(goodreads_id)
        token = set_access_token(@access_token, @access_token_secret)
        response = token.get("http://www.goodreads.com/user/compare/#{ goodreads_id }.xml")

        data = ''
        if response.code == '200'
          data = response.body
        end
        {:code => response.code, :data => response.body}
      end

      def user_book_review(user_id, book_id)
        token = set_access_token(@access_token, @access_token_secret)
        response = token.get("http://www.goodreads.com/review/show_by_user_and_book.xml", 
                      'user_id' => user_id,
                      'book_id' => book_id,
                      'key' => APP_CONFIG['goodreads_key'])
        data = ''
        if response.code == '200'
          data = response.body
        end
        {:code => response.code, :data => response.body}
      end

  end
end