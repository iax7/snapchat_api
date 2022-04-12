# frozen_string_literals: true

require "dotenv/load"
require "sinatra"
require "sinatra/reloader"
require "pry"

require_relative "api/snap"
require_relative "lib/storage"

set :port, 5000

include Storage
snap_api = Snap.new(ENV["SC_CLIENT_ID"], ENV["SC_CLIENT_SECRET"], ENV["SC_REDIRECT_URI"])

# Step 1
get "/" do
  url_str = snap_api.authorize_url

  redirect url_str
end

# Step 2: Exchange code for access token
get "/snapchat" do
  code = params[:code]
  state = params[:state]

  response = snap_api.generate_tokens(code)
  return response.body unless response.success?

  tokens = response.body.slice(:access_token, :refresh_token)
  save_tokens(tokens)

  "token saved!"
end

# Step 3: Refresh token
get "/refresh" do
  refresh_token = load_tokens[:refresh_token]
  response = snap_api.refresh_token(refresh_token)
  return response.body unless response.success?

  tokens = response.body.slice(:access_token, :refresh_token)
  save_tokens(tokens)

  "token refreshed!"
end
