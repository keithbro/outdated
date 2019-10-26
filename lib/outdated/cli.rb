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

      # Bundler.load.dependencies does not include non dev dependencies, not
      # sure why. TODO figure out.
      # current_dependencies = Bundler.load.dependencies.map { |dep| [dep.name, dep] }.to_h
      gemfile_specs = current_specs # .select { |spec| current_dependencies.key? spec.name }

      print "Inspecting gem versions"

      gemfile_specs.sort_by(&:name).each do |used|
        name = used.name
        # puts "\n" + name
        # next unless name == 's3_backup'

        spec_set = Outdated::RubyGems.spec_set(name)
        next if spec_set.empty?

        used = spec_set.get(used.version)
        recommended = spec_set.recommend(used, one_week_ago)

        outdated = recommended.version > used.version
        too_new = recommended.version < used.version

        if outdated
          puts "\n#{name} #{used.version} is outdated. " \
               "#{recommended.version} published #{recommended.created_at}."
          exit_status = 1
        elsif too_new
          puts "\n#{name} #{used.version} is too new and may contain bugs or " \
               'vulnerabilities that are as yet unknown. It was published ' \
               "#{used.created_at}. For now use #{recommended.version} " \
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
