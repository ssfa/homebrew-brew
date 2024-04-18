# frozen_string_literal: true
require 'formula'
require_relative './concern'

module Ssfa
  # 현재 Formula 의 scripts 폴더의 툴들 설치를 지원한다.
  module RubyScriptInstallHelper
    extend Ssfa::Concern

    included do
      homepage(Dir.chdir(__dir__) { url = `git remote get-url origin`.strip; /https/ =~ url ? url : "https://github.com/#{url.split('.com:').last}" })
      url Dir.chdir(__dir__) { `git remote get-url origin`.strip }, using: :git, branch: 'main'

      depends_on "ruby@3.2"
    end

    def install
      install_command
    end

    def install_command
      require 'pathname'
      ENV['GEM_HOME'] = libexec

      command = name
      source = Pathname.glob(File.expand_path("../../../scripts/#{command}*", __FILE__)).first
      p({source: source, command: command})
      FileUtils.cp source, command
      FileUtils.chmod 'u+x', command
      bin.install command
      bin.env_script_all_files(libexec / "bin", GEM_HOME: libexec)
    end
  end
end