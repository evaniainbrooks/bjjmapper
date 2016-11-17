class Admin::TemplatesController < Admin::AdminController

  def show
    model_name = params.fetch(:model, nil)
    @arg_name = params.fetch(:arg, model_name)
    @template_name = "templates/#{params.fetch(:id, nil)}"
    klass = model_name.capitalize.constantize
    @model_instance = klass.last.decorate

    render
  end
end
