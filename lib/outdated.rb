# frozen_string_literal: true

require 'active_support/time'
require 'pry'

require_relative 'outdated/cli'
require_relative 'outdated/ruby_gems'
require_relative 'outdated/ruby_gems/spec_set'
require_relative 'outdated/version'

module Outdated
  class Error < StandardError; end
end
