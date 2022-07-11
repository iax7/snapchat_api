# frozen_string_literals: true

require "yaml"
require "time"

# Module for storing data.
module Storage
  TOKENS_FILE = "tokens.yml"

  # @param  data[Hash<Symbol->Object>]
  # @returns [void] the yaml contained
  def save_tokens(data)
    File.open(TOKENS_FILE, "w") do |file|
      file.write(YAML.dump(add_time(data)))
    end
    puts "Tokens saved!"
  end

  # @returns [Hash<Symbol->Object>] the yaml contained
  def load_tokens
    YAML.load_file(TOKENS_FILE)
  rescue StandardError => e
    puts "Error: #{e.message}"
    {}
  end

  # @param hash[Hash<Symbol->Object>]
  # @returns [Hash<Symbol->Object>] the yaml contained
  def add_time(hash) = hash.tap { _1.store(:timestap, Time.now.to_s) }
end
