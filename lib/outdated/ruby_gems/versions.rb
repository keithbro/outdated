module Outdated
  module RubyGems
    class Versions
      def self.from_response(response)
        return [] if response.code == 404

        body = response.body
        versions = JSON.parse(body).map do |version|
          version['created_at'] = Time.parse(version['created_at'])
          version['number'] = Gem::Version.new(version['number'])

          OpenStruct.new(version)
        end
        new(versions)
      end

      attr_reader :versions

      def initialize(versions)
        @versions = versions
      end

      def empty?
        versions.empty?
      end

      def get(ver)
        versions.find { |version| version.number == ver }
      end

      def recommend(used, cut_off)
        versions.find do |spec|
          version = spec.number.to_s.split(/\./).map(&:to_i)
          used_version = used.number.to_s.split(/\./).map(&:to_i)
          prerelease = spec.prerelease
          too_new = cut_off < spec.created_at
          minor_or_major_upgrade =
            version[0] > used_version[0] || version[1] > used_version[1]

          !prerelease && !too_new && !minor_or_major_upgrade
        end
      end
    end
  end
end
