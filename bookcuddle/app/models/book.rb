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
end
