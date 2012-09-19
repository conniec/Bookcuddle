class Discussion
  include Mongoid::Document

  field :user_1, type: Integer
  field :user_2, type: Integer
  field :book_id, type: Integer
  field :book_name, type: String

  has_and_belongs_to_many :users

  attr_accessible :user_1, :user_2, :book_id
end
