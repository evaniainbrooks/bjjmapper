class Admin::DirectorySegmentsController < Admin::AdminController
  def new
    respond_to do |format|
      format.html
    end
  end

  def create
    segment = DirectorySegment.create(create_params)

    respond_to do |format|
      format.html {
        if segment.child?
          redirect_to directory_segment_path(country: segment.parent_segment.name, city: segment.name, edit: 1, create: 1) 
        else
          redirect_to directory_segment_path(country: segment.name, edit: 1, create: 1) 
        end
      }
    end
  end

  private

  def create_params
    p = params.require(:directory_segment).permit(
      :distance,
      :zoom,
      :abbreviations,
      :parent_segment_id,
      :name,
      :description,
      :coordinates
    )

    p[:abbreviations] = p[:abbreviations].split(',').collect(&:strip)
    p
  end
end
