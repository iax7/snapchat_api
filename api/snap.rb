# frozen_string_literals: true

require "securerandom"
require "faraday"
require "faraday/net_http"

class Snap
  def initialize(client_id, client_secret,redirect_uri)
    @client_id = client_id
    @client_secret = client_secret
    @redirect_uri = redirect_uri

    @connection = Faraday.new("https://accounts.snapchat.com") do |f|
      f.request :url_encoded
      f.response :json, parser_options: { symbolize_names: true }
      f.adapter :net_http
    end
  end

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

  def generate_tokens(code)
    data = {
      code: code,
      client_id: client_id,
      client_secret: client_secret,
      grant_type: "authorization_code",
      redirect_uri: redirect_uri
    }
    response = connection.post("/login/oauth2/access_token", data)

    response
  end

  def refresh_token(refresh_token)
    data = {
      refresh_token: refresh_token,
      client_id: client_id,
      client_secret: client_secret,
      grant_type: "refresh_token"
    }
    response = connection.post("/login/oauth2/access_token", data)

    response
  end

  private

  attr_reader :client_id, :client_secret, :redirect_uri, :connection

  def state = SecureRandom.alphanumeric(30)
end