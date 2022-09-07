# frozen_string_literal: true

module Http
  module Feedonomics
    # Contains all method to create from FeedonomicsClient API https://app.swaggerhub.com/apis/feedonomicsjustin/Feedonomics/2
    module Create
      # @see https://app.swaggerhub.com/apis/feedonomicsjustin/Feedonomics/2#/Authentication/post_login
      # @param payload [Hash<Symbol->Object>]
      # @return [Faraday::Response]
      def login(payload)
        connection.post("login", payload.to_json)
      end

      # @see https://app.swaggerhub.com/apis/feedonomicsjustin/Feedonomics/2#/Database/post_accounts__account_id__dbs
      # @param account_id [String]
      # @param payload [Hash<Symbol->Object>]
      # @return [Faraday::Response]
      def create_db(account_id, payload)
        connection.post("accounts/#{account_id}/dbs", payload.to_json)
      end

      # @see https://app.swaggerhub.com/apis/feedonomicsjustin/Feedonomics/2#/Imports/get_dbs__db_id__imports
      # @param db_id [String]
      # @param payload [Hash<Symbol->Object>]
      # @return [Faraday::Response]
      def create_import(db_id, payload)
        connection.post("dbs/#{db_id}/imports", payload.to_json)
      end

      # @see https://app.swaggerhub.com/apis/feedonomicsjustin/Feedonomics/2#/Exports/get_dbs__db_id__exports
      # @param db_id [String]
      # @param payload [Hash<Symbol->Object>]
      # @return [Faraday::Response]
      def create_export(db_id, payload)
        connection.post("dbs/#{db_id}/exports", payload.to_json)
      end

      # @see https://app.swaggerhub.com/apis/feedonomicsjustin/Feedonomics/2#/info
      # @param db_id [String]
      # @param payload [Hash<Symbol->Object>]
      # @return [Faraday::Response]
      def create_ftp_accounts(db_id, payload)
        connection.post("dbs/#{db_id}/ftp_accounts", payload.to_json)
      end


      # @see https://app.swaggerhub.com/apis/feedonomicsjustin/Feedonomics/2#/DBGroups/post_dbs__db_id__move_db_to_db_group
      # @param db_id [String]
      # @param payload [Hash<Symbol->Object>]
      # @return [Faraday::Response]
      def move_db_to_group(db_id, payload)
        connection.post("dbs/#{db_id}/move_db_to_db_group", payload.to_json)
      end
    end
  end
end
