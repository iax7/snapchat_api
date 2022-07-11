# frozen_string_literals: true

require "pry"
require "dotenv/load"
require "sinatra"
require "sinatra/reloader"

require_relative "api/snap_auth"
require_relative "api/snap_account_client"
require_relative "api/feedonomics_client"
require_relative "lib/storage"

set :port, 5000
set :views, Proc.new { File.join(root, "templates") }

include Storage

snap_auth_api = SnapAuth.new(ENV["SC_CLIENT_ID"], ENV["SC_CLIENT_SECRET"], ENV["SC_REDIRECT_URI"])
fdx_auth_api = FeedonomicsClient.new_login(ENV["FDX_USERNAME"], ENV["FDX_PASSWORD"])

get "/ping" do
  @data = "pong"
  erb :index
end

# Index page
get "/" do
  @data = load_tokens

  erb :index
end

# Step 1
get "/auth" do
  url_str = snap_auth_api.authorize_url

  redirect url_str
end

# Step 2: Exchange code for access token
get "/snapchat" do
  code = params[:code]
  state = params[:state]

  response = snap_auth_api.generate_tokens(code)
  return response.body unless response.success?

  tokens = response.body.slice(:access_token, :refresh_token)
  save_tokens(tokens)

  @data = load_tokens
  @data.store :status, "token saved!"

  erb :index
end

# Step 3: Refresh token
get "/refresh" do
  refresh_token = load_tokens[:refresh_token]
  response = snap_auth_api.refresh_token(refresh_token)
  return response.body unless response.success?

  tokens = response.body.slice(:access_token, :refresh_token)
  save_tokens(tokens)

  @data = load_tokens
  @data.store :status, "token refreshed!"

  erb :index
end

# Get all organization
get "/organizations" do
  snap_account_api = SnapAccountClient.new(load_tokens[:access_token])

  response = snap_account_api.organizations
  return response.body&.to_json unless response.success?

  @organizations = response.body
  erb :organizations
end

# Get all organization
get "/sync_catalog" do
  organization_id = params[:organization_id]

  return if organization_id.nil? || organization_id.empty?

  # Feedonomics API
  # Get all accounts from feedonomics
  account_response = fdx_auth_api.accounts
  return account_response.body&.to_json unless account_response.success?

  account_response = JSON.parse(account_response.body)
  account = account_response.first

  # Get all databases from current account if in feedonomics
  databases = fdx_auth_api.dbs(account["id"])
  return databases.body&.to_json unless databases.success?

  databases = JSON.parse(databases.body)

  database = if ENV['FDX_DATABASE_ID'].empty?
               databases.find { |db| db["name"] == "STORE:#{ENV['BC_STORE_HASH']}" }
             else
               databases.find { |db| db["id"] == ENV['FDX_DATABASE_ID'] }
             end

  if database.nil?
    database = fdx_auth_api.create_db(account["id"], { name: "STORE:#{ENV['BC_STORE_HASH']}" })
    return database.body&.to_json unless database.success?

    database = JSON.parse(database.body)
  end

  # Get import configuration from a current database
  import_response = fdx_auth_api.imports(database["id"])
  return import_response.body&.to_json unless import_response.success?

  import_response = JSON.parse(import_response.body)

  @import = if import_response.empty?
              payload = { name: "BigCommerce Integration",
                          join_type: "product_feed",
                          file_location: "preprocess_script",
                          tags: {
                            platform: "Bigcommerce"
                          },
                          timeout: 1800,
                          url: "https://haproxy-preprocess.feedonomics.com/preprocess/run_preprocess.php?connection_info[client]=bigcommerce&connection_info[protocol]=api&connection_info[additional_image_sizes]=true&connection_info[access_token]=#{ENV['BC_TOKEN']}&connection_info[store_hash]=#{ENV['BC_STORE_HASH']}&connection_info[store_url]=#{ENV['BC_STORE_URL']}&connection_info[client_id]=#{ENV['BC_CLIENT_ID']}&file_info[request_type]=get&",
                          preprocess_info: {
                            connection_info: {
                              client: "bigcommerce",
                              protocol: "api",
                              additional_image_sizes: true,
                              access_token: ENV['BC_TOKEN'],
                              store_hash: ENV['BC_STORE_HASH'],
                              store_url: ENV['BC_STORE_URL'],
                              client_id: ENV['BC_CLIENT_ID']
                            },
                            file_info: {
                              request_type: "get"
                            },
                            actions: []
                          }
              }

              import_response = fdx_auth_api.create_import(database["id"], payload)
              JSON.parse(import_response.body)
            else
              import_response.first
            end

  # Get ftp configuration from a current database
  ftp_response = fdx_auth_api.ftp_accounts(database["id"])
  return ftp_response.body&.to_json unless ftp_response.success?

  ftp_account = JSON.parse(ftp_response.body)
  if ftp_account.empty?
    create_ftp_response = fdx_auth_api.create_ftp_accounts(database["id"], {})
    return create_ftp_response.body&.to_json unless create_ftp_response.success?

    ftp_account = JSON.parse(create_ftp_response.body)
  end

  # Get export configuration from a current database
  export_response = fdx_auth_api.exports(database["id"])
  return export_response.body&.to_json unless export_response.success?

  export_response = JSON.parse(export_response.body)
  @export = if export_response.empty?
              payload = {
                name: "Export Snapchat",
                file_name: "#{ENV['BC_STORE_HASH']}.txt",
                protocol: "ftp", protocol_info: "",
                host: ftp_account["host"],
                username: ftp_account["username"],
                password: ftp_account["password"],
                export_fields: [
                  { field_name: "", export_field_name: "id", required: "" },
                  { field_name: "", export_field_name: "title", required: "" },
                  { field_name: "", export_field_name: "description", required: "" },
                  { field_name: "", export_field_name: "link", required: "" },
                  { field_name: "", export_field_name: "image_link", required: "" },
                  { field_name: "", export_field_name: "availability", required: "" },
                  { field_name: "", export_field_name: "price", required: "" },
                  { field_name: "", export_field_name: "condition", required: "" },
                  { field_name: "", export_field_name: "brand", required: "" },
                  { field_name: "", export_field_name: "gtin", required: "" },
                  { field_name: "", export_field_name: "mpn", required: "" },
                  { field_name: "", export_field_name: "age_group", required: "" },
                  { field_name: "", export_field_name: "color", required: "" },
                  { field_name: "", export_field_name: "gender", required: "" },
                  { field_name: "", export_field_name: "item_group_id", required: "" },
                  { field_name: "", export_field_name: "google_product_category", required: "" },
                  { field_name: "", export_field_name: "product_type", required: "" },
                  { field_name: "", export_field_name: "adult", required: "" },
                  { field_name: "", export_field_name: "custom_label_0", required: "" },
                  { field_name: "", export_field_name: "custom_label_1", required: "" },
                  { field_name: "", export_field_name: "custom_label_2", required: "" },
                  { field_name: "", export_field_name: "custom_label_3", required: "" },
                  { field_name: "", export_field_name: "custom_label_4", required: "" },
                  { field_name: "", export_field_name: "size", required: "" },
                  { field_name: "", export_field_name: "additional_image_link", required: "" },
                  { field_name: "", export_field_name: "sale_price", required: "" },
                  { field_name: "", export_field_name: "sale_price_effective_date", required: "" }
                ],
                export_selector: "true",
                file_header: "",
                file_footer: "",
                threshold: "0",
                delimiter: "tab",
                compression: "",
                quoted_fields: "0",
                delta_export: "0",
                deduplicate_field_name: "",
                export_format: "delimited",
                include_column_names: "1",
                json_minify_type: "full",
                export_encoding: "",
                enclosure: "",
                escape: "",
                strip_characters: ["\r", "\n", "\t"],
                show_empty_tags: "0",
                show_empty_parent_tags: "1",
                use_cdata: "0",
                xml_write_document_tag: "1",
                zip_inner_file_name: "",
                timeout: 1200,
                time_between_attempts: 30,
                max_attempts: 3,
                row_sort: "",
                row_order: "ASC",
                row_limit: 0,
                tags: [
                  {
                    tag: "export_template",
                    value: "snap"
                  }
                ],
                export_index_field: ""
              }
              export_response = fdx_auth_api.create_export(database["id"], payload)
              JSON.parse(export_response.body)
            else
              export_response.first
            end

  # SnapChat API
  # Get all catalogs from Snap account and organization
  snap_account_api = SnapAccountClient.new(load_tokens[:access_token])
  response_catalogs = snap_account_api.catalogs(organization_id)
  return response_catalogs.body&.to_json unless response_catalogs.success?

  catalogs = response_catalogs.body[:catalogs]
  @catalog = if catalogs.empty?
               catalog_payload = { catalogs: [{ organization_id: organization_id, name: "BigCommerce Catalog", vertical: "COMMERCE" }] }
               response_catalog = snap_account_api.create_catalog(organization_id, catalog_payload)
               return response_catalog.body&.to_json unless response_catalog.success?

               response_catalog.body[:catalogs].first
             else
               catalogs.first
             end

  response_product_feed = snap_account_api.product_feeds(@catalog[:catalog][:id])
  return response_product_feed.body&.to_json unless response_product_feed.success?

  products_feed = response_product_feed.body
  @product_feed = if products_feed[:product_feeds].empty?
                    products_feed_payload = { product_feeds: [
                      { catalog_id: @catalog[:catalog][:id],
                        name: "BC Catalog Sync",
                        default_currency: "USD",
                        status: "ACTIVE",
                        schedule: { url: "ftp://#{@export["host"]}/#{@export["file_name"]}",
                                    username: @export["username"],
                                    password: @export["password"],
                                    interval_type: "HOURLY",
                                    interval_count: "1",
                                    timezone: "PST",
                                    minute: "15" } }] }
                    response_product_feed = snap_account_api.create_product_feeds(@catalog[:catalog][:id], products_feed_payload)
                    return response_product_feed.body&.to_json unless response_product_feed.success?

                    response_product_feed.body[:product_feeds].first
                  else
                    products_feed[:product_feeds].first
                  end
  erb :sync_catalog
end

# Get all ads account for the organization
get "/ad_account" do
  snap_account_api = SnapAccountClient.new(load_tokens[:access_token])
  response = snap_account_api.ad_accounts(ENV["SC_ORGANIZATION_ID"])
  return response.body&.to_json unless response.success?

  @ad_accounts = response.body
  erb :ad_account
end
