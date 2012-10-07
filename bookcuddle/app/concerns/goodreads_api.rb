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

    def get_user_book_status(user_id, book_id)
      res = user_book_review(user_id, book_id)

      return [] if res[:data] =~ /review not found/

      doc = Nokogiri::XML(res[:data])
      statuses = doc.xpath("//review//user_statuses//user_status")

      book_statuses = []
      statuses.each do |status|
        book_statuses << { :percent => status.css('percent').text,
                            :created_at => status.css('created_at').text,
                            :updated_at => status.css('updated_at').text,
                            :page => status.css('page').text }
      end
      book_statuses
    end
    
    def get_user_friends(user_id)
      res = user_friends(user_id)

      friends_info = []
      return friends_info if res[:code] != '200'

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
        if ((book.css('your_review rating').text == 'to-read' && book.css('their_review rating').text == 'to-read') ||
            (book.css('your_review rating').text == 'currently-reading' && book.css('their_review rating').text == 'currently-reading') )
          unread_books << { :title => book.css('book title').text,
                            :id => book.css('book id').text,
                            :url => book.css('book url').text,
                            :your_review => book.css('your_review rating').text,
                            :their_review => book.css('their_review rating').text
                          }
        end
      end
      unread_books
    end

    def get_book_info(goodreads_id)
      res = book_show(goodreads_id)
      doc = Nokogiri::XML(res[:data])
      book_xml = doc.xpath("//book")
      book_info = {}

      book_info[:description] = book_xml.css('description').text
      book_info[:num_pages] = book_xml.css('num_pages').text
      book_info[:average_rating] = book_xml.css('average_rating').text
      book_info[:publication_year] = book_xml.css('publication_year').text
      book_info[:image_url] = book_xml.css('image_url').first.text

      book_authors = []
      doc_authors = doc.xpath("//book//authors//author")
      doc_authors.each do |author|
        book_authors << { :name => author.css('name').text,
                          :id => author.css('id').text,
                          :image_url => author.css('image_url').text 
                        }
      end
      book_info[:authors] = book_authors
      
      book_info
    end

    #params should be a dict containing the following:
    #quote[author_name]: Name of the quote author (required)
    #quote[author_id]: id of the author
    #quote[book_id]: id of the book from which the quote was taken
    #quote[body]: The quote! (required)
    #quote[tags]: Comma-separated tags
    def add_quote(params)
      res = post_quote(params)
      res
    end

    def add_status(params)
      puts params
      res = post_status(params)
      if res.empty?
        false
      end
      true
    end

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
        #No OAuth needed for this endpoint
        goodreads_key = APP_CONFIG['goodreads_key']
        url = "http://www.goodreads.com/review/show_by_user_and_book.xml?user_id=#{user_id}&book_id=#{book_id}&key=#{goodreads_key}"

        response = HTTParty.get(url)
        data = ''
        if response.code == '200'
          data = response.body
        end
        {:code => response.code, :data => response.body}
      end

      def book_show(book_id)
        #No Oauth needed for this endpoint
        goodreads_key = APP_CONFIG['goodreads_key']
        url = "http://www.goodreads.com/book/show/#{book_id}?format=xml&key=#{goodreads_key}"

        response = HTTParty.get(url)
        data = ''
        if response.code == '200'
          data = response.body
        end
        {:code => response.code, :data => response.body}
      end

      def post_quote(params)
        token = set_access_token(@access_token, @access_token_secret)

        #Make sure params includes a book_id
        return {} if !params.has_key?(:book_id)

        post_params = {}
        post_params['quote[author_name]'] = params[:author_name]
        post_params['quote[author_id]'] = params[:author_id]
        post_params['quote[book_id]'] = params[:book_id]
        post_params['quote[body]'] = params[:body]
        puts post_params

        response = token.post("http://www.goodreads.com/quotes.xml", post_params)

        data = ''
        if response.code == '200' or response.code == '201'
          data = response.body
        end
        {:code => response.code, :data => response.body}
      end

      def post_status(params)
        token = set_access_token(@access_token, @access_token_secret)

        #Make sure params includes a book_id
        return {} if !params.has_key?("book_id")

        #Make sure params has a page or percent update
        if params.has_key("percent") || params.has_key("page")
          response = token.post("http://www.goodreads.com/user_status.xml", {
                                  'user_status[book_id]' => params[:book_id],
                                  'user_status[page]' => params[:page],
                                  'user_status[percent]' => params[:percent],
                                  'user_status[body]' => params[:body]
            })
          data = ''
          if response.code == '200'
            data = response.body
          end
          {:code => response.code, :data => response.body}
        end
        {}
      end

  end
end