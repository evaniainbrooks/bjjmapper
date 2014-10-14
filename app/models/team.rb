class Team
  include Mongoid::Document
  field :name, type: String
  field :description, type: String
  field :image, type: String
  has_many :locations
  has_many :users
  belongs_to :parent_team, class_name: 'Team'

  def as_json(args)
    super(args.merge(except: [:_id, :parent_team_id])).merge({
      :id => self.id.to_s,
      :parent_team_id => self.parent_team_id.to_s,
    })
  end
end
