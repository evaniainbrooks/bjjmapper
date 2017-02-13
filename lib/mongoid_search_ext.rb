module MongoidSearchExt
  module Search
    def search(str, options={})
      self.where({ '$text' => { '$search' => "\"#{str}\"" } }.merge(options))
    end
  end
end
