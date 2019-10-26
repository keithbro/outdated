require 'http'

module Outdated
  module RubyGems
    def self.spec_set(name)
      response = HTTP.get("https://rubygems.org/api/v1/versions/#{name}.json")
      Outdated::RubyGems::SpecSet.from_response(response)
    end
  end
end
