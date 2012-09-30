require 'goodreads_api'

class Book
  include Mongoid::Document
  field :goodreads_id, type: Integer
  field :title, type: String
  field :image_url, type: String
  field :pub_year, type: String
  field :description, type: String
  field :average_rating, type: String
  field :num_pages, type: String
  field :authors, type: Array, :default => []

  has_many :discussion
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
