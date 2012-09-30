class Discussion
  include Mongoid::Document

  field :user_1, type: String
  field :user_2, type: String
  field :book_goodreads_id, type: Integer

  #Cached values
  field :user_1_name, type: String
  field :user_2_name, type: String
  field :book_name, type: String

  has_and_belongs_to_many :users
  belongs_to :book

  attr_accessible :user_1, :user_2, :book_id, :book_name, :user_1_name, :user_2_name
end
