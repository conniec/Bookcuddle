require 'goodreads_api'

class Book
  include Mongoid::Document
  include API

  field :goodreads_id, type: Integer
  field :title, type: String
  field :image_url, type: String
  field :pub_year, type: String
  field :description, type: String
  field :average_rating, type: String
  field :num_pages, type: String
  field :authors, type: Array, :default => []

  has_many :discussion
  attr_accessible :title, :image_url, :goodreads_id, :pub_year, :description, :average_rating, :num_pages, :authors


  def self.find_or_create_by_goodreads(access_token, access_token_secret, goodreads_id)
    #Get the book info from Goodreads
    puts 'creating a book!'
    begin
      book = self.find_by(:goodreads_id => goodreads_id)
      book
    rescue
      @gr_connection = API::Goodreads.new(access_token, access_token_secret)
      book_info = @gr_connection.get_book_info(goodreads_id)
      'here is my info!'
      puts book_info

      return false if book_info == {}
      
      #Create a book in model
      @book = self.new(book_info)
      @book.goodreads_id = goodreads_id
      @book.save
    end
  end

  private
    def create_connection
      @gr_connection = API::Goodreads.new(session[:access_token], session[:access_token_secret])
    end

  attr_accessible :title, :image_url, :goodreads_id, :title
  
  def self.find_or_fetch_from_goodreads(goodreads_book_id)
    begin
      self.find_by(:goodreads_id => goodreads_book_id)
    rescue
      self.fetch_from_goodreads(goodreads_book_id)
    end
  end
  
  def self.fetch_from_goodreads(goodreads_book_id)
    self.create_connection
    @gr_connection.get_book_info(goodreads_book_id)
  end
end
