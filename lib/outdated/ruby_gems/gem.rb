module Outdated
  module RubyGems
    class Gem
      def self.from_response(response)
        return new if response.code == 404

        body = response.body
        specs = JSON.parse(body).map { |spec| Outdated::RubyGems::Spec.from_response_object(spec) }
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

      def recommend(currently_used_spec, cut_off)
        recommended_spec = specs.find do |spec|
          semver = spec.version.to_s.split(/\./).map(&:to_i)
          currently_used_semver = currently_used_spec.version.to_s.split(/\./).map(&:to_i)
          prerelease = spec.prerelease
          too_new = cut_off < spec.created_at
          minor_or_major_upgrade =
            semver[0] > currently_used_semver[0] || semver[1] > currently_used_semver[1]

          !prerelease && !too_new && !minor_or_major_upgrade
        end

        code =
          if recommended_spec.nil?
            Outdated::IMMATURE
          elsif recommended_spec > currently_used_spec
            Outdated::OUTDATED
          elsif recommended_spec < currently_used_spec
            Outdated::IMMATURE
          end

        [recommended_spec, code]
      end
    end
  end
end
