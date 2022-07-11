#!/usr/bin/env ruby
# frozen_string_literal: true

require "pry"
require "dotenv/load"

require_relative "api/snap_auth"
require_relative "lib/storage"

first_arg, *args = ARGV

include Storage
snap_api = SnapAuth.new(ENV["SC_CLIENT_ID"], ENV["SC_CLIENT_SECRET"], ENV["SC_REDIRECT_URI"])

if first_arg == "-1"
  url_str = snap_api.authorize_url

  puts url_str
  `open -u "#{url_str}"`

  exit 0
end

# 2. Exchange code for access token
# http -f POST https://accounts.snapchat.com/login/oauth2/access_token code=$code client_id=$SC_CLIENT_ID client_secret=$SC_CLIENT_SECRET grant_type=authorization_code redirect_uri=$redirect_uri
if first_arg == "-2"
  code = args.first
  response = snap_api.generate_tokens(code)
  exit 1 unless response.success?

  tokens = response.body.slice(:access_token, :refresh_token)
  save_tokens(tokens)
end

# 3. Refresh token
# http -f POST https://accounts.snapchat.com/login/oauth2/access_token refresh_token=$refresh_token client_id=$SC_CLIENT_ID client_secret=$SC_CLIENT_SECRET grant_type=refresh_token
if first_arg == "-3"
  refresh_token = load_tokens[:refresh_token]
  response = snap_api.refresh_token(refresh_token)
  exit 1 unless response.success?

  tokens = response.body.slice(:access_token, :refresh_token)
  save_tokens(tokens)
end
