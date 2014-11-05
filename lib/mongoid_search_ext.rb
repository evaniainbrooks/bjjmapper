module MongoidSearchExt
  module Search
    # @params
    # str: Query string based on mongodb text search.
    def search(str, options={})
      self.where(:id.in => self.search_ids(str, options))
    end

    def search_ids(str, options={})
      options[:limit] = options[:limit] || 50
      res = self.mongo_session.command({ text: self.collection.name, search: str}.merge(options))
      res['results'].collect{|x| x['obj']['_id'].to_s }
    end
  end
end
