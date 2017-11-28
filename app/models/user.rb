class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :recoverable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :rememberable, :validatable

  def admin?
    self.role == "admin"
  end
end
