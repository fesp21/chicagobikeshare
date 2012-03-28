class Profile < ActiveRecord::Base
  
  belongs_to :user, :dependent => :destroy
  has_many :activity_items, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :feature_points, :dependent => :destroy
  has_many :feature_polygons, :dependent => :destroy
  has_many :votes, :dependent => :destroy
  
  validates :user_agent, :uniqueness => { :scope => :client_ip }, :allow_blank => true
  validates :user_id, :uniqueness => true, :allow_blank => true
  
  def self.find_or_create_by_request_fingerprint(request)
    identifying_attrs = { 
      :user_agent => request.env['HTTP_USER_AGENT'], 
      :client_ip  => request.remote_ip 
    }
    
    where(identifying_attrs).first || create(identifying_attrs)
  end
  
end