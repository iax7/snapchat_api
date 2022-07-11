# frozen_string_literals: true

require "faraday"
require "faraday/net_http"
require_relative "http/snap_account/create"
require_relative "http/snap_account/read"
require_relative "http/snap_account/update"
require_relative "http/snap_account/delete"

# Snapchat API client
class SnapAccountClient
  include Http::SnapAccount::Create
  include Http::SnapAccount::Read
  include Http::SnapAccount::Update
  include Http::SnapAccount::Delete

  BASE_URL = "https://adsapi.snapchat.com/v1/"

  # @param access_token [String]
  # @return [self]
  def initialize(access_token)
    @access_token = access_token

    @connection = Faraday.new(BASE_URL) do |faraday|
      faraday.request :authorization, "Bearer", access_token
      faraday.request :json
      faraday.response :json, parser_options: { symbolize_names: true }
      faraday.adapter :net_http
    end
  end

  private

  attr_reader :access_token, :connection
end
