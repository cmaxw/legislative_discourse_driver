class Discourse
  def initialize
    @client = DiscourseApi::Client.new(ENV["DISCOURSE_URL"])
    @client.api_key = ENV["DISCOURSE_API_KEY"]
    @client.api_username = ENV["DISCOURSE_USERNAME"]
  end

  def create_topic(attributes)
    @client.create_topic(attributes)
  end

  def create_post(attributes)
    @client.create_post(attributes)
  end

  def search(search)
    @client.search(search)
  end

  def get_topic(topic_id)
    @client.topic(topic_id)
  end

  def get_topic_link(topic_id)
    topic = get_topic(topic_id)
    "[#{topic["title"]}](#{ENV["DISCOURSE_URL"]}/t/#{topic_id})"
  end

  def categories
    @client.categories
  end
end
