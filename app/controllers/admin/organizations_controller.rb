class Admin::OrganizationsController < Admin::AdminController
  def new
    respond_to do |format|
      format.html
    end
  end

  def create
    org = Organization.create(create_params)

    respond_to do |format|
      format.html { redirect_to new_admin_organization_path(created: 1) }
    end
  end

  private

  def create_params
    params.require(:organization).permit(
      :name,
      :abbreviation,
      :image,
      :image_large,
      :description,
      :website,
      :email
    )
  end
end
