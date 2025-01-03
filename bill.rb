class Bill
  attr_reader :session, :number, :token, :sponsor_name

  def initialize(session:, number:, token: ENV["UTAH_LEGISLATURE_DEVELOPER_TOKEN"])
    @number = number
    @session = session
    @token = token
    get_metadata
  end

  private

  def get_metadata
    response = Faraday.get("https://glen.le.utah.gov/bills/#{session}/#{number}/#{token}")
    metadata = JSON.parse(response.body)
    @sponsor_name = metadata["billVersionList"].last["versionSponsorName"]
  end
end
