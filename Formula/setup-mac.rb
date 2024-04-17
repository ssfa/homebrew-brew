# frozen_string_literal: true

require_relative '../lib/ssfa/thor_script_install_helper'

class SetupMac < Formula
  include Ssfa::ThorScriptInstallHelper
  version '0.0.1'

  command = 'setup-mac'

  desc "기본 개발자 환경을 구성한다."

  def install
    ENV['GEM_HOME'] = libexec
    system("gem install --no-document rainbow")
    system("gem install --no-document rouge")

    %w[.zshrc .vimrc setup-mac.readme.md].each do |filename|
      source = from_git("scripts/#{filename}")
      FileUtils.cp source, filename
      share.install filename
    end
    
    install_command
  end

  def caveats
    <<~EOS

     설치후 새로운 터미널 열고 실행:
        setup-mac help
        setup-mac setup_terminal
        setup-mac install_gui_apps

    EOS
  end

  private
  def from_git(filename)
    Pathname.new(filename)
  end

  # For debugging
  private
  def from_tap(filename)
    Pathname.new(File.expand_path("../../#{filename}", __FILE__))
  end
end

