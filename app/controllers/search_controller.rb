class SearchController < ApplicationController
  def show
    query = params.fetch(:q, '')

    head :bad_request and return false unless query.present?

    @addresses = GeocodersHelper.search(query)
    @locations = begin
      ids = Location.search_ids(query)
      Location.verified.where(:_id.in => ids)
    end

    @users = begin
      ids = User.search_ids(query)
      User.jitsukas.where(:_id.in => ids).where(:role.ne => Role::ANONYMOUS).where(:flag_display_directory => true)
    end

    @teams = begin
      ids = Team.search_ids(query)
      Team.where(:_id.in => ids)
    end
    
    tracker.track('search',
      query: query,
      locations: @locations.count,
      addresses: @addresses.count,
      users: @users.count,
      teams: @teams.count
    )

    @responses = [@addresses, @locations, @users, @teams].zip(['address', 'location', 'user', 'team']).inject([]) do |a, e|
      a.push({ results: e[0], name: e[1] })
      a
    end

    respond_to do |format|
      format.json do
        head :no_content and return unless @responses.present?
        render
      end
    end
  end
end
