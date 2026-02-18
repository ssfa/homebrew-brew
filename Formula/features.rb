# frozen_string_literal: true

require_relative '../lib/ssfa/brew_ruby_helper'

class Features < Formula
  include Ssfa::BrewRubyHelper
  desc "gh 를 이용해서 git branch 에서 이슈 번호를 이용해서 제목을 붙여준다."
  homepage "https://github.com/ssfa/ssfa-tools"
  url "https://github.com/ssfa/ssfa-tools", using: :git, branch: 'main'

  depends_on 'gh'
  depends_on 'ruby@3.4'

  def install
    command = "features"

    ENV['GEM_HOME'] = libexec
    Dir.chdir(command) do
      run_yellow_cmd("#{gem_path} build #{command}.gemspec --output=#{command}.gem")
      run_yellow_cmd("#{gem_path} install --no-document #{command}.gem")
    end
    bin.install(libexec / "bin/#{command}")
    bin.env_script_all_files(libexec / "bin", GEM_HOME: libexec, PATH: "#{ruby_bin}:$PATH")
  end
end
