require 'http'

module Outdated
  module RubyGems
    def self.versions(name)
      response = HTTP.get("https://rubygems.org/api/v1/versions/#{name}.json")
      Outdated::RubyGems::Versions.from_response(response)
    end
  end
end
