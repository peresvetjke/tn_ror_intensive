# class Search
#   def search(type)
#     case type
#     when :job
#       "search_jobs"
#     when :user 
#       "search_users"
#     else
#       raise 'Unknown search type'
#     end
#   end
# end

class JobSearch
  def call
    "search_jobs"
  end
end

class UserSearch
  def call
    "search_jobs"
  end
end

class Search
  TYPES = {
    job: JobSearch,
    user: UserSearch
  }

  def search(type)
    raise 'Unknown search type' unless TYPES.key? type
    TYPES[type].new.call
  end
end