# frozen_string_literal: true
require 'formula'
require 'active_support/concern'

# 현재 Formula 의 scripts 폴더의 툴들 설치를 지원한다.
module RubyScriptInstallHelper
  extend ActiveSupport::Concern

  class_methods {attr_rw :command}

  included do
    delegate command: :"self.class"

    homepage(Dir.chdir(__dir__){url=`git remote get-url origin`.strip; /https/ =~ url ? url : "https://github.com/#{url.split('.com:').last}"})
    url Dir.chdir(__dir__){`git remote get-url origin`.strip}, using: :git, tag: 'main'

    depends_on "ruby@2.7"
  end

  def install
    install_command
  end
  
  def install_command
    require 'pathname'
    ENV['GEM_HOME'] = libexec

    _command = command || name
    source   = Pathname.glob(File.expand_path("../../scripts/#{_command}*", __FILE__)).first
    FileUtils.cp source, _command
    FileUtils.chmod 'u+x', _command
    bin.install _command
    bin.env_script_all_files(libexec/"bin", GEM_HOME: libexec)
  end
end
