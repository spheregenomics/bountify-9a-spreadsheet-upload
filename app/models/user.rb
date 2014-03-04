class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation

  has_many :batches

  #after_create :create_task_list

  def clear_authentication_token!
    update_attribute(:authentication_token, nil)
  end

  #def create_task_list
  #  task_lists.create!(name: "My first list")
  #end

  def first_list
    batches.first
  end
end
