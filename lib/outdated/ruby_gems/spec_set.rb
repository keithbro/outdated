module Outdated
  module RubyGems
    class SpecSet
      def self.from_response(response)
        return new if response.code == 404

        body = response.body
        specs = JSON.parse(body).map do |spec|
          spec['created_at'] = Time.parse(spec['created_at'])
          spec['version'] = Gem::Version.new(spec['number'])

          OpenStruct.new(spec)
        end
        new(specs)
      end

      attr_reader :specs

      def initialize(specs = [])
        @specs = specs
      end

      def empty?
        specs.empty?
      end

      def size
        specs.size
      end

      def first
        specs.first
      end

      def get(version)
        specs.find { |spec| spec.version == version }
      end

      def recommend(status_quo_spec, cut_off)
        specs.find do |spec|
          semver = spec.version.to_s.split(/\./).map(&:to_i)
          status_quo_semver = status_quo_spec.version.to_s.split(/\./).map(&:to_i)
          prerelease = spec.prerelease
          too_new = cut_off < spec.created_at
          minor_or_major_upgrade =
            semver[0] > status_quo_semver[0] || semver[1] > status_quo_semver[1]

          !prerelease && !too_new && !minor_or_major_upgrade
        end
      end
    end
  end
end
