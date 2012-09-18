class User
    include Mongoid::Document
    field :name, type: String
    field :email, type: String
    # field :password_salt, type: String
    # field :password_hash, type: String
    field :goodreads_id, type: Integer
    field :access_token, type: String
    field :access_token_secret, type: String

    attr_accessible :email, :name, :goodreads_id

    #attr_accessible :email, :password, :password_confirmation, :password_digest
  
    #attr_accessor :password
    #has_secure_password
    #before_save :encrypt_password
  
    #validates_confirmation_of :password
    validates_uniqueness_of :email
    #validates_presence_of :email

    def authenticate(email, password)
        user = User.find_by(email: email)
        if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
            user
        else
            nil
        end
    end
  
    def encrypt_password
        if password.present?
            self.password_salt = BCrypt::Engine.generate_salt
            self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
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
