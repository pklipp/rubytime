class Invoice < ActiveRecord::Base
  belongs_to :client
  belongs_to :user
  has_many :activities
  has_many :projects, :through => :activity
  
  validates_presence_of :client_id, :name, :created_at, :user_id
  validates_uniqueness_of :name
  validates_length_of(:name, :within => 2..20)
  
end
