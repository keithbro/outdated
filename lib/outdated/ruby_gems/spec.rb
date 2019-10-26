module Outdated
  module RubyGems
    class Spec
      include Comparable

      def self.from_response_object(response_object)
        Outdated::RubyGems::Spec.new(created_at: response_object['created_at'].to_time,
                                     name: response_object['name'],
                                     prerelease: response_object['prerelease'],
                                     version: ::Gem::Version.new(response_object['number']))
      end

      attr_reader :created_at, :name, :prerelease, :version

      def initialize(args)
        @created_at = args[:created_at]
        @version = args[:version]
      end

      def <=>(other)
        version <=> other.version
      end
    end
  end
end
