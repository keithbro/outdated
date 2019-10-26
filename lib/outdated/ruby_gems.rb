require 'http'

module Outdated
  module RubyGems
    def self.gem(name)
      response = HTTP.get("https://rubygems.org/api/v1/versions/#{name}.json")
      Outdated::RubyGems::Gem.from_response(name, response)
    end
  end
end
