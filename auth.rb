#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "pry"
require "securerandom"
require "faraday"
require "faraday/net_http"
require "dotenv/load"

TOKENS_FILE = "tokens.yml"

def save_tokens(data)
  File.open(TOKENS_FILE, 'w') do |file|
    file.write(YAML.dump(data))
  end
  puts "Tokens saved!"
end

def load_tokens = YAML.load_file(TOKENS_FILE)

connection = Faraday.new("https://accounts.snapchat.com") do |f|
  f.request :url_encoded
  f.response :json, parser_options: { symbolize_names: true }
  f.adapter :net_http
end

first_arg, *args = ARGV

if first_arg == "-1"
  state = SecureRandom.alphanumeric(30)
  query = {
    response_type: "code",
    client_id: ENV["SC_CLIENT_ID"],
    redirect_uri: ENV["SC_REDIRECT_URI"],
    scope: "snapchat-marketing-api",
    state: state
  }

  auth_path = "/login/oauth2/authorize"
  url = connection.url_prefix.merge(auth_path)
  url.query = URI.encode_www_form(query)
  puts url.to_s
  `open -u "#{url.to_s}"`

  exit 0
end

# 2. Exchange code for access token
# http -f POST https://accounts.snapchat.com/login/oauth2/access_token code=$code client_id=$SC_CLIENT_ID client_secret=$SC_CLIENT_SECRET grant_type=authorization_code redirect_uri=$redirect_uri
if first_arg == "-2"
  code = args.first
  data = {
    code: code,
    client_id: ENV["SC_CLIENT_ID"],
    client_secret: ENV["SC_CLIENT_SECRET"],
    grant_type: "authorization_code",
    redirect_uri: ENV["SC_REDIRECT_URI"]
  }
  response = connection.post("/login/oauth2/access_token", data)
  exit 1 unless response.success?

  tokens = response.body.slice(:access_token, :refresh_token)
  save_tokens(tokens)
end

# 3. Refresh token
# http -f POST https://accounts.snapchat.com/login/oauth2/access_token refresh_token=$refresh_token client_id=$SC_CLIENT_ID client_secret=$SC_CLIENT_SECRET grant_type=refresh_token
if first_arg == "-3"
  data = {
    refresh_token: load_tokens[:refresh_token],
    client_id: ENV["SC_CLIENT_ID"],
    client_secret: ENV["SC_CLIENT_SECRET"],
    grant_type: "refresh_token"
  }
  response = connection.post("/login/oauth2/access_token", data)
  exit 1 unless response.success?

  tokens = response.body.slice(:access_token, :refresh_token)
  save_tokens(tokens)
end
