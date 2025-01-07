class Discourse
  def initialize
    @client = DiscourseApi::Client.new(ENV["DISCOURSE_URL"])
    @client.api_key = ENV["DISCOURSE_API_KEY"]
    @client.api_username = ENV["DISCOURSE_USERNAME"]
  end

  def create_topic(attributes)
    @client.create_topic(attributes)
  end
end
