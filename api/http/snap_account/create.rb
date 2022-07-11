# frozen_string_literal: true

module Http
  module SnapAccount
    # Contains all method to create from Snapchat API https://marketingapi.snapchat.com/docs/
    module Create

      # @see https://marketingapi.snapchat.com/docs/#get-all-ad-accounts
      # @param organization_id [Integer]
      # @param payload [Hash<Symbol->Object>]
      # @return [Faraday::Response]
      def create_catalog(organization_id, payload)
        connection.post("organizations/#{organization_id}/catalogs", payload)
      end

      # @see https://marketingapi.snapchat.com/docs/#get-a-specific-product-feed
      # @param catalog_id [Integer]
      # @param payload [Hash<Symbol->Object>]
      # @return [Faraday::Response]
      def create_product_feeds(catalog_id, payload)
        connection.post("catalogs/#{catalog_id}/product_feeds", payload)
      end
    end
  end
end
