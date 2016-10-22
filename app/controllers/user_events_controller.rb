class UserEventsController < ApplicationController
  before_action :set_user
  before_action :redirect_legacy_bsonid

  before_action :validate_time_range, only: [:index]

  decorates_assigned :user, :event, :events

  def index
    @events = @user.schedule.events_between_time(@start_param, @end_param)

    respond_to do |format|
      format.json do
        if @events.count == 0
          render status: :no_content
        else
          render
        end
      end
    end
  end

private
  def validate_time_range
    start_param = params.fetch(:start, nil)
    head :bad_request and return false unless start_param.present?
    @start_param = DateTime.parse(start_param).to_time

    end_param = params.fetch(:end, nil)
    head :bad_request and return false unless end_param.present?
    @end_param = DateTime.parse(end_param).to_time
  end

  def redirect_legacy_bsonid
    redirect_legacy_bsonid_for(@user, params[:user_id], user_events_path(@user))
  end

  def set_user
    id_param = params.fetch(:user_id, '')
    @user = User.find(id_param)
    head :bad_request and return false unless @user.present?
  end
end
