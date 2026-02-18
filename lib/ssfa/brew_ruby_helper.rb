# frozen_string_literal: true
require 'formula'
require 'pathname'
require_relative './concern'

module Ssfa
  # gem 빌드 지원
  module BrewRubyHelper
    extend Ssfa::Concern

    RUBY = 'ruby@3.4'

    def run_yellow_cmd(cmd)
      puts "\033[1;33m#{cmd}\033[0m\n"
      puts `#{cmd}`
    end

    def ruby_prefix
      @ruby_prefix ||=
        begin
          brew_path = %w[/usr/local/bin/brew /opt/homebrew/bin/brew].find { |i| File.exist?(i) }
          Pathname.new(`#{brew_path} --prefix #{RUBY}`.strip)
        end
    end

    def gem_exec = @gem_exec ||= ruby_prefix / 'bin' / 'gem'

    def ruby_bin = @ruby_bin ||= ruby_prefix / 'bin'

    def ruby_path = @ruby_path ||= ruby_bin / 'ruby'
  end
end
