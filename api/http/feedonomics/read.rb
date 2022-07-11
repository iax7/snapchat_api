# frozen_string_literal: true

module Http
  module Feedonomics
    # Contains all method to read from FeedonomicsClient API https://app.swaggerhub.com/apis/feedonomicsjustin/Feedonomics/2
    module Read
      # @seehttps://app.swaggerhub.com/apis/feedonomicsjustin/Feedonomics/2#/Accounts/get_user_accounts
      # @return [Faraday::Response]
      def accounts
        connection.get("user/accounts")
      end

      # @see https://app.swaggerhub.com/apis/feedonomicsjustin/Feedonomics/2#/Database/get_accounts__account_id__dbs
      # @param account_id [String]
      # @return [Faraday::Response]
      def dbs(account_id)
        connection.get("accounts/#{account_id}/dbs")
      end

      # @see https://app.swaggerhub.com/apis/feedonomicsjustin/Feedonomics/2#/Imports/get_dbs__db_id__imports
      # @param db_id [String]
      # @return [Faraday::Response]
      def imports(db_id)
        connection.get("dbs/#{db_id}/imports")
      end

      # @see https://app.swaggerhub.com/apis/feedonomicsjustin/Feedonomics/2#/Exports/get_dbs__db_id__exports
      # @param db_id [String]
      # @return [Faraday::Response]
      def exports(db_id)
        connection.get("dbs/#{db_id}/exports")
      end

      # @see https://app.swaggerhub.com/apis/feedonomicsjustin/Feedonomics/2#/info
      # @param db_id [String]
      # @return [Faraday::Response]
      def ftp_accounts(db_id)
        connection.get("dbs/#{db_id}/ftp_accounts")
      end
    end
  end
end
