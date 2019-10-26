# frozen_string_literal: true

module Outdated
  module CLI
    def self.run
      one_week_ago = Time.now - 7 * 24 * 60 * 60 # 1 week ago
      Bundler.ui = Bundler::UI::Shell.new
      current_specs = Bundler.definition.resolve
      definition = Bundler.definition(true)
      definition.resolve_remotely!
      exit_status = 0

      current_dependencies = Bundler.load.dependencies.map { |dep| [dep.name, dep] }.to_h
      gemfile_specs = current_specs.select { |spec| current_dependencies.key? spec.name }

      gemfile_specs.sort_by(&:name).each do |used|
        name = used.name
        # next unless name == 'http'

        versions = Outdated::RubyGems.versions(name)
        next if versions.empty?

        used = versions.get(used.version)
        recommended = versions.recommend(used, one_week_ago)

        outdated = recommended.number > used.number
        too_new = recommended.number < used.number

        if outdated
          puts "\n#{name} #{used.number} is outdated. " \
               "#{recommended.number} published #{recommended.created_at}."
          exit_status = 1
        elsif too_new
          puts "\n#{name} #{used.number} is too new and may contain bugs or " \
               'vulnerabilities that are as yet unknown. It was published ' \
               "#{used.created_at}. For now use #{recommended.number} " \
               'instead.'
          exit_status = 1
        else
          putc '.'
        end
      end

      puts "\nGem versions deemed to be sufficiently up-to-date." if exit_status == 0
      exit_status
    end
  end
end
