class Redis
  def cache(params)
    key = params[:key] || raise(":key parameter is required!") 
    recalculate = params[:recalculate] || nil
    expire = params[:expire] || nil 
    timeout = params[:timeout] || 0 
    default = params[:default] || nil 
    yaml_value = if (value = get(key)).nil? || recalculate
      begin 
        value = Timeout::timeout(timeout) { yield(self) }
      rescue Timeout::Error 
        value = default
      end 
    
      set(key, YAML::dump(value)) 
      expire(key, expire) if expire 
      get(key)
    else 
      value
    end 

    YAML::load(yaml_value)
  end 
end
