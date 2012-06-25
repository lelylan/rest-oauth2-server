# Daily requests of a Resource Owner on a specific client

if defined?(Mongoid::Document)
  module Oauth2Provider
    class DailyRequest
      include Mongoid::Document

      field :created_at, type: Time                       # creation time
      field :time_id                                      # unique key for the day
      field :day                                          # request day
      field :month                                        # request month
      field :year                                         # request year
      field :times, type: Integer, default: 0             # daily request times

      # resource owner's client access
      embedded_in :access, inverse_of: :daily_requests
    end
  end
elsif defined?(ActiveRecord::Base)
  module Oauth2Provider
    class DailyRequest < ActiveRecord::Base
      set_table_name :oauth2_provider_daily_requests
      belongs_to :access
    end
  end
elsif defined?(MongoMapper::Document)
  raise NotImplementedError
elsif defined?(DataMapper::Resource)
  raise NotImplementedError
end

module Oauth2Provider
  class DailyRequest
    after_create :init_times

    # Increment the times counter that track the number of
    # requests a client have made in behalf of a resource
    # owner in a specific day
    def increment!
      self.times += 1
      self.save
    end

    class << self

      # Find a daily requests record
      def find_day(time)
        time_id = time_id(time)
        where(time_id: time_id)
      end

      # Define an identifier for a specific day
      def time_id(time)
        time.strftime("%Y%m%d")
      end
    end

    private

    # Add statistical informations
    def init_times
      self.day     = self.created_at.strftime("%d")
      self.month   = self.created_at.strftime("%m")
      self.year    = self.created_at.strftime("%Y")
      self.time_id = self.class.time_id(created_at)
      self.save
    end

  end
end
