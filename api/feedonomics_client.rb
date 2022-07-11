# frozen_string_literals: true

require "faraday"
require "faraday/excon"

require_relative "http/feedonomics/create"
require_relative "http/feedonomics/read"
require_relative "http/feedonomics/update"
require_relative "http/feedonomics/delete"

# FeedonomicsClient API client
class FeedonomicsClient
  BASE_URL = "https://meta.feedonomics.com/api.php"

  include Http::Feedonomics::Create
  include Http::Feedonomics::Read
  include Http::Feedonomics::Update
  include Http::Feedonomics::Delete

  class << self
    # @param username [String]
    # @param password [String]
    # @param method [String]
    # @return [self]
    def new_login(username , password, method = "token")
      raise ArgumentError, "Username or Password are not present." if username.empty? || password.empty?

      response = new.login({ username: username, password: password, method: method })
      raise ArgumentError, "Error: #{response.body}" unless response.success?

      response = JSON.parse(response.body)
      new(response["token"])
    end
  end

  # @param token [String]
  # @return [self]
  def initialize(token = nil)
    @token = token
    @connection = Faraday.new(BASE_URL) do |faraday|
      faraday.headers = headers(token) if token
      faraday.adapter :excon
      faraday.response :logger, nil, { headers: true, bodies: true }
    end
  end

  private

  attr_reader :token, :connection

  # @param token [String]
  # @return [Hash<String->String>]
  def headers(token)
    {
      "Accept" => "application/json",
      "Content-Type" => "application/json",
      "x-api-key" => token,
    }.freeze
  end
end
