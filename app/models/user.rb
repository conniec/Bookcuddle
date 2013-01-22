class User
    include Mongoid::Document
    field :name, type: String
    field :email, type: String
    field :goodreads_id, type: Integer
    field :access_token, type: String
    field :access_token_secret, type: String
    field :friends, type: Array, :default => []

    has_and_belongs_to_many :discussions

    attr_accessible :email, :name, :goodreads_id, :friends

    validates_uniqueness_of :email

    def add_friend(user)
      puts 'add me as a friend!!'
      friend_id = user.id
      if !self.friends.include?(friend_id.to_s)
        self.friends << friend_id.to_s
        self.save
      end
    end

    def self.get_or_create_goodreads_user(goodreads_id, goodreads_name)
      begin
        user = User.find_by(goodreads_id: goodreads_id)
      rescue
        user = User.new(name: goodreads_name, goodreads_id: goodreads_id)
      end
    end
end
