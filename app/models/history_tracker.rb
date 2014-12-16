require 'mongoid-history'

class HistoryTracker
  include Mongoid::History::Tracker
end
