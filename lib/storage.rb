# frozen_string_literals: true

require "yaml"

module Storage
  TOKENS_FILE = "tokens.yml"

  def save_tokens(data)
    File.open(TOKENS_FILE, 'w') do |file|
      file.write(YAML.dump(add_time(data)))
    end
    puts "Tokens saved!"
  end

  def load_tokens = YAML.load_file(TOKENS_FILE)

  def add_time(hash) = hash.tap { _1.store(:timestap, Time.now) }
end