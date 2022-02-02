#!/usr/bin/env ruby
# frozen_string_literal: true

require 'thor'
require 'pathname'
require 'erb'

module WorksAlias
  
  module Location
    def home; @home ||= Pathname(Dir.home); end
    def works; @works ||= home / 'works'; end
  end
  
  # ref https://github.com/tmuxinator/tmuxinator/blob/master/completion
  class CLI < Thor
    include Location
    Error = Class.new(StandardError)

    desc "init [zsh,bash]", "shell 환경에 맞는 소스를 출력한다."
    def init(shell = nil)
      raise Error, "works-alias init [zsh, bash]를 입력" unless [nil, 'zsh', 'bash'].any? {|i| i == shell}
      puts <<~BASH unless shell
        #.zshrc, .bashrc 에 다음 라인을 추가한다.
        eval "$(works-alias init zsh)"
      BASH
      exit 0 unless %w[zsh bash].include?(shell)

      bash_script = <<~BASH
        function works(){
          cd <%= works %>
        }
        <% works.glob("*").select(&:directory?).each do |path| -%>
        function w-<%= path.basename %>(){
          cd <%= path %>/$1
        }
        <% end -%>
        function cdg(){
          cd $(git rev-parse --show-toplevel)
        }
      BASH

      erb = RUBY_VERSION =~ /^2.(4|5)/ ? ERB.new(bash_script, nil, '-') : ERB.new(bash_script, trim_mode: '-')
      puts erb.result(binding)
    end

    desc "install", "works 설치"
    def install
      [['bash', home / '.bashrc'], ['zsh', home / '.zshrc']]
        .map {|shell, path| [path, %Q[eval "$(works-alias init #{shell})"]]}
        .select {|path, _| path.exist?}
        .reject {|path, line| path.read.include? line}
        .each {|path, line| puts "Install to #{line} => #{path.basename}"}
        .each {|path, line| path.open('a+') {|f| f.write line + "\n"}}
    end
    
    desc 'commands', 'w-*'
    def commands
      puts works.glob("*").select(&:directory?).map{|i| "w-#{i.basename}"} * "\n"
    end

    desc 'subcommands', 'w-*'
    def subcommands(command)
      work = command.gsub(/w-/,'')
      puts works.glob("*").select{|i|i.basename.to_s == work}.first.glob('*').select(&:directory?).map(&:basename).map(&:to_s) * "\n"
    end

    desc 'make_dirs', 'works 밑에 추천할만한 디렉토리들 생성'
    def make_dirs
      require 'fileutils'
      %w[rust ruby rails go python general typescript flutter android deno node c cpp swift].each{ |i| FileUtils.mkdir_p(works / i)  }
    end
  end
end

begin
  WorksAlias::CLI.start
rescue WorksAlias::CLI::Error => err
  puts "ERROR: #{err.message}"
  exit 1
end

