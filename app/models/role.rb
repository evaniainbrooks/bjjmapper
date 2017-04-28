class Role
  ANONYMOUS = 'anonymous'
  SUPER_USER = 'super_user'
  API_USER = 'api_user'
  USER = 'user'
  READ_ONLY_USER = 'read_only_user'
  MODERATOR = 'moderator'

  ALL_ROLES = [ANONYMOUS, READ_ONLY_USER, USER, MODERATOR, API_USER, SUPER_USER].freeze

  def self.power(role)
    return ALL_ROLES.index(role) || 0
  end

  def locations_scope
  end

  def can_delete? o
  end

  def can_edit? o
  end

  def can_view? o
  end
end
