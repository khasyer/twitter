class User < ActiveRecord::Base

  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: {with: VALID_EMAIL_REGEX}
  validates :password, presence: true, length: {minimum: 6}
  
  has_secure_password
  has_many :microposts, dependent: :destroy
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships, foreign_key: "followed_id", 
            dependent: :destroy, class_name: "Relationship"
  has_many :followers, through: :reverse_relationships, source: :follower
  
  
  before_save { self.email = self.email.downcase }
  before_create :create_remember_token
  
    def feed
    # Это предварительное решение. См. полную реализацию в "Following users".
    Micropost.where("user_id = ?", id)
    end
  
    def User.new_remember_token
    SecureRandom.urlsafe_base64
    end

    def User.encrypt(token)
      Digest::SHA1.hexdigest(token.to_s)
    end
    
    def follow!(other_user)
      relationships.create!(follower_id: id, followed_id: other_user.id)
    end
    
    def unfollow!(other_user)
      relationships.find_by(follower_id: id, followed_id: other_user.id).destroy
    end
    
    def following?(other_user)
      relationships.find_by(follower_id: id, followed_id: other_user.id)
    end

    def feed
    Micropost.from_users_followed_by(self)
    end
    
    private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
    
   
 end