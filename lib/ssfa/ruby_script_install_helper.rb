# frozen_string_literal: true
require 'formula'
require_relative './concern'

module Ssfa
  # 현재 Formula 의 scripts 폴더의 툴들 설치를 지원한다.
  module RubyScriptInstallHelper
    extend Ssfa::Concern

    RUBY = 'ruby@3.4'

    included do
      homepage(Dir.chdir(__dir__) { url = `git remote get-url origin`.strip; /https/ =~ url ? url : "https://github.com/#{url.split('.com:').last}" })
      url Dir.chdir(__dir__) { `git remote get-url origin`.strip }, using: :git, branch: 'main'

      depends_on RUBY
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

    def install = install_command

    def install_command
      require 'pathname'
      ENV['GEM_HOME'] = libexec

      command = name
      source = Pathname.glob(File.expand_path("../../../scripts/#{command}*", __FILE__)).first
      p({source: source, command: command})
      FileUtils.cp source, command
      FileUtils.chmod 'u+x', command
      bin.install command
      bin.env_script_all_files(libexec / "bin", GEM_HOME: libexec, PATH: "#{ruby_bin}:$PATH")
    end
  end
end
