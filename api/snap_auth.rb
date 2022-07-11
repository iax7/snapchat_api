# frozen_string_literals: true

require "securerandom"
require "faraday"
require "faraday/net_http"

# Snapchat API client
class SnapAuth
  BASE_URL = "https://accounts.snapchat.com"

  # @param client_id [String]
  # @param client_secret [String]
  # @param redirect_uri [String]
  # @return [self]
  def initialize(client_id, client_secret, redirect_uri)
    @client_id = client_id
    @client_secret = client_secret
    @redirect_uri = redirect_uri

    @connection = Faraday.new(BASE_URL) do |faraday|
      faraday.request :url_encoded
      faraday.response :json, parser_options: { symbolize_names: true }
      faraday.adapter :net_http
    end
  end

  # @return [String]
  def authorize_url
    query = {
      response_type: "code",
      client_id: client_id,
      redirect_uri: redirect_uri,
      scope: "snapchat-marketing-api",
      state: state
    }

    auth_path = "/login/oauth2/authorize"
    url = connection.url_prefix.merge(auth_path)
    url.query = URI.encode_www_form(query)

    url.to_s
  end

  # @param code [String]
  # @return [Faraday::Response]
  def generate_tokens(code)
    data = {
      code: code,
      client_id: client_id,
      client_secret: client_secret,
      grant_type: "authorization_code",
      redirect_uri: redirect_uri
    }

    connection.post("/login/oauth2/access_token", data)
  end

  # @param refresh_token [String]
  # @return [Faraday::Response]
  def refresh_token(refresh_token)
    data = {
      refresh_token: refresh_token,
      client_id: client_id,
      client_secret: client_secret,
      grant_type: "refresh_token"
    }

    connection.post("/login/oauth2/access_token", data)
  end

  private

  attr_reader :client_id, :client_secret, :redirect_uri, :connection

  # @return [String]
  def state = SecureRandom.alphanumeric(30)
end
