class Team
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  track_history   :on => :all,
                  :modifier_field => :modifier, # adds "belongs_to :modifier" to track who made the change, default is :modifier
                  :modifier_field_inverse_of => :nil, # adds an ":inverse_of" option to the "belongs_to :modifier" relation, default is not set
                  :version_field => :version,   # adds "field :version, :type => Integer" to track current version, default is :version
                  :track_create   =>  true,    # track document creation, default is false
                  :track_update   =>  true,     # track document updates, default is true
                  :track_destroy  =>  true     # track document destruction, default is false
  field :name, type: String
  field :description, type: String
  field :image, type: String
  field :image_large, type: String
  field :primary_color_index, type: String
  has_many :locations
  has_many :users
  belongs_to :parent_team, class_name: 'Team', inverse_of: :child_teams
  has_many :child_teams, class_name: 'Team', inverse_of: :parent_team

  validates :name, presence: true

  has_mongoid_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :url => "/images/:class/:attachment/:style/:id.:extension", :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  def as_json(args)
    super(args.merge(except: [:_id, :parent_team_id, :modifier_id])).merge({
      :id => self.id.to_s,
      :modifier_id => self.modifier_id.to_s,
      :parent_team_id => self.parent_team_id.try(:to_s)
    })
  end

  def to_param
    [id, name.parameterize].join('-')
  end
end
