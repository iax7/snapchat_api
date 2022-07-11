# frozen_string_literal: true

module Http
  module SnapAccount
    # Contains all method to read from Snapchat API https://marketingapi.snapchat.com/docs/
    module Read
      # @see https://marketingapi.snapchat.com/docs/#get-authenicated-user
      # @return [Faraday::Response]
      def me
        connection.get("me")
      end

      # @see https://marketingapi.snapchat.com/docs/#get-all-organizations
      # @return [Faraday::Response]
      def organizations
        connection.get("me/organizations")
      end

      # @see https://marketingapi.snapchat.com/docs/#get-all-ad-accounts
      # @param organization_id [Integer]
      # @return [Faraday::Response]
      def ad_accounts(organization_id)
        connection.get("organizations/#{organization_id}/adaccounts")
      end

      # @see https://marketingapi.snapchat.com/docs/#funding-sources
      # @param organization_id [Integer]
      # @return [Faraday::Response]
      def funding_sources(organization_id)
        connection.get("organizations/#{organization_id}/fundingsources")
      end

      # @see https://marketingapi.snapchat.com/docs/#get-all-catalogs
      # @param organization_id [Integer]
      # @return [Faraday::Response]
      def catalogs(organization_id)
        connection.get("organizations/#{organization_id}/catalogs")
      end

      # @see https://marketingapi.snapchat.com/docs/#get-all-product-feeds
      # @param catalog_id [Integer]
      # @return [Faraday::Response]
      def product_feeds(catalog_id)
        connection.get("catalogs/#{catalog_id}/product_feeds")
      end
    end
  end
end
