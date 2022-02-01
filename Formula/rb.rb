# frozen_string_literal: true
 
require_relative '../lib/ruby_script_install_helper'

class Rb < Formula
  include RubyScriptInstallHelper
  homepage "https://github.com/thisredone/rb"
  desc "ruby text processor"
  version '0.0.1'

  def install
    ENV['GEM_HOME'] = libexec
    system "gem", "install", '--no-document', "awesome_print"
    system "gem", "install", '--no-document', "table_print"
    
    install_command
  end
end

