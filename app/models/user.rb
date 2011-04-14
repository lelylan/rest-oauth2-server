class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Lelylan::Document::Base

  field :uri
  field :email
  field :name
  field :password_hash
  field :password_salt
  field :admin, type: Boolean, default: false

  attr_accessible :email, :name, :password

  attr_accessor :password
  before_save :encrypt_password

  validates :password, presence: true, on: :create
  # TODO: add password length
  #validates :password, length: {min: 6}, empty: true
  validates :email, presence: true
  validates :email, uniqueness: true
  validates :email, email: true

  def self.authenticate(email, password)
    user = where(email: email).first
    user.verify(password) if user
  end

  def verify(password)
    if password_hash == BCrypt::Engine.hash_secret(password, password_salt)
      self
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

  def admin?
    self.admin
  end
end
