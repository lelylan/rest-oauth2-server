# Access info related to a resource owner using a specific
# client (block and statistics)

class OauthAccess
  include Mongoid::Document
  include Mongoid::Timestamps

  field :client_uri                           # client identifier (internal)
  field :resource_owner_uri                   # resource owner identifier
  field :blocked, type: Time, default: nil    # authorization block (a user block a single client)

  embeds_many :oauth_daily_requests           # daily requests (one record per day)

  validates :client_uri, presence: true
  validates :resource_owner_uri, presence: true


  # Block the resource owner delegation to a specific client
  def block!
    self.blocked = Time.now
    self.save
    OauthToken.block_access!(client_uri, resource_owner_uri)
    OauthAuthorization.block_access!(client_uri, resource_owner_uri)
  end

  # Unblock the resource owner delegation to a specific client
  def unblock!
    self.blocked = nil
    self.save
  end

  # Check if the status is or is not blocked
  def blocked?
    !self.blocked.nil?
  end

  # Increment the daily accesses
  def accessed!
    daily_requests.increment!
  end

  # A daily requests record (there is one per day)
  #
  #   @params [String] time we want to find the requests record
  #   @return [OauthDailyRequest] requests record
  def daily_requests(time = Time.now)
    find_or_create_daily_requests(time)
  end

  # Give back the last days in a friendly format.It is used to 
  # generate graph for statistics
  def chart_days
    daily_requests = self.oauth_daily_requests.limit(10)
    days = daily_requests.map(&:created_at)
    days.map { |d| d.strftime("%b %e") }
  end

  # Give the number of accesses for the last days. It is used
  # to generate graph for statistics
  def chart_times
    access_times = self.oauth_daily_requests.limit(10)
    access_times.map(&:times)
  end


  private

    def find_or_create_daily_requests(time)
      daily_requests = oauth_daily_requests.find_day(time).first
      daily_requests = oauth_daily_requests.create(created_at: time) unless daily_requests
      return daily_requests
    end

    def daily_id(time)
      time.year + time.month + time.day
    end

end
