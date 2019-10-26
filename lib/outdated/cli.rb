# frozen_string_literal: true

module Outdated
  module CLI
    def self.run
      filename = '.outdated.json'
      options = File.exist?(filename) ? JSON.parse(File.read(filename)) : {}
      exclusions = options["exclusions"] || []

      Bundler.ui = Bundler::UI::Shell.new
      current_specs = Bundler.definition.resolve
      definition = Bundler.definition(true)
      definition.resolve_remotely!
      exit_status = 0

      # Bundler.load.dependencies does not include non dev dependencies, not
      # sure why. TODO figure out.
      # current_dependencies = Bundler.load.dependencies.map { |dep| [dep.name, dep] }.to_h
      gemfile_specs = current_specs # .select { |spec| current_dependencies.key? spec.name }

      print "Inspecting gem versions"

      gemfile_specs.sort_by(&:name).each do |used|
        name = used.name
        gem_exclusions = exclusions.find { |exc| exc['gem'] == name } || {}
        excluded_rules = gem_exclusions['rules'] || []

        gem = Outdated::RubyGems.gem(name)
        next if gem.specs.empty?

        used = gem.get(used.version)
        recommended_spec, code = gem.recommend(used, 1.week.ago)

        if code == Outdated::OUTDATED
          next if excluded_rules.include? Outdated::OUTDATED

          puts "\n#{name} #{used.version} is outdated. " \
               "#{recommended_spec.version} published #{recommended_spec.created_at}."
          exit_status = 1
          next
        end

        if code == Outdated::IMMATURE
          next if excluded_rules.include? Outdated::IMMATURE

          puts "\n#{name} #{used.version} is too new and may contain bugs or " \
               'vulnerabilities that are as yet unknown. It was published ' \
               "#{used.created_at}."
          puts " For now use #{recommended_spec.version} instead." if recommended_spec.present?
          exit_status = 1
          next
        end

        putc '.'
      end

      puts "\nGem versions deemed to be sufficiently up-to-date." if exit_status.zero?
      exit_status
    end
  end
end
