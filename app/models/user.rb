class User < ActiveRecord::Base

  before_save { self.username = username.downcase}
  before_save :encrypt_password
  
  validates :username, presence: true, length: { maximum: 50}
                    
  
  def self.authenticate(username, password)
    user = find_by_username(username.downcase)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end   
  
  
  def encrypt_password
    if password_hash.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password_hash, password_salt)
    end
  end
  
  def remove_password
    self.password_hash = nil
  end
  
  
end
