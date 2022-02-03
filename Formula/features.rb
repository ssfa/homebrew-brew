# frozen_string_literal: true
 
require_relative '../lib/thor_script_install_helper'

class Features < Formula
  include ThorScriptInstallHelper
  desc "ghi 를 이용해서 git branch 에서 이슈 번호를 이용해서 제목을 붙여준다."

  version '0.0.5'
  depends_on 'gh'

  def install
    ENV['GEM_HOME'] = libexec
    system("gem install --no-document rainbow")
    
    install_command
  end
end

