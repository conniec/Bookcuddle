class Book
  include Mongoid::Document
  field :goodreads_id, type: Integer
  field :title, type: String
  field :image_url, type: String
  field :pub_year, type: String
  field :description, type: String
  field :average_rating, type: String
  field :num_pages, type: String
end
