class Redis
  def cache(params)
    key = params[:key] || raise(":key parameter is required!") 
    recalculate = params[:recalculate] || nil
    expire = params[:expire] || nil 
    timeout = params[:timeout] || 0 
    default = params[:default] || nil 
    
    value = nil
    begin
      value = get(key)
    rescue StandardError => e
      ::Rails.logger.error(e)
      return default 
    end
    
    yaml_value = if value.nil? || recalculate
      begin 
        value = Timeout::timeout(timeout) { yield(self) }
      rescue Timeout::Error 
        value = default
      end 
   
      if !value.nil?
        set(key, YAML::dump(value)) 
        expire(key, expire) if expire 
        get(key)
      end
    else 
      value
    end 

    yaml_value.nil? ? nil : YAML::load(yaml_value)
  end 
end
