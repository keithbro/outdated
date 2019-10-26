module Outdated
  module RubyGems
    class Spec
      include Comparable

      def self.from_response_object(name, response_object)
        Outdated::RubyGems::Spec.new(created_at: response_object['created_at'].to_time,
                                     name: name,
                                     prerelease: response_object['prerelease'],
                                     version: ::Gem::Version.new(response_object['number']))
      end

      attr_reader :created_at, :name, :prerelease, :version

      def initialize(args)
        @created_at = args[:created_at] or raise ArgumentError, "missing created_at"
        @name = args[:name] or raise ArgumentError, "missing name"

        @prerelease = args[:prerelease]
        raise ArgumentError, "missing prerelease" if @prerelease.nil?

        @version = args[:version] or raise ArgumentError, "missing version"
      end

      def <=>(other)
        version <=> other.version
      end
    end
  end
end
