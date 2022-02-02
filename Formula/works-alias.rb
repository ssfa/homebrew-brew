# frozen_string_literal: true
require_relative '../lib/thor_script_install_helper'

class WorksAlias < Formula
  include ThorScriptInstallHelper
  desc "$HOME/works 내의 디렉토리들에 대한 순회 및 자동 완성"
  command 'works-alias'
  version '0.0.2'

  private
  def works
    @works ||= begin
      Pathname(Dir.home(ENV['USER'])) / 'works'
    end.tap{|path| !path.exist? and raise "#{path} 를 만들어주세요."}
  end

  def _aliases
    Dir[works  / '*']
      .map{|i| Pathname(i)}
      .select(&:directory?)
      .map{|i| ["w-#{i.basename}", i.basename]}
  end

  public
  def install
    install_command

    _aliases.each do |cmd, _|

      zsh_complete = "_#{cmd}"
      File.open(zsh_complete, 'w'){|f| f.write(<<~ZSH)}
        #compdef #{cmd}
        #autoload
        _#{cmd}() {
          local subcommands
          subcommands=(${(f)"$(works-alias subcommands #{cmd})"})
          #compadd $subcommands
          if (( CURRENT == 2 )); then
            _alternative \\
              'subcommands:: _describe -t subcommands "works-alias subcommands #{cmd}" subcommands'
          fi
          return
        }
        _#{cmd}
      ZSH
      zsh_completion.install zsh_complete => zsh_complete

      bash_complete = "#{cmd}.bash"
      File.open(bash_complete, 'w'){|f| f.write(<<~BASH)}
        #!/usr/bin/env bash

        _#{cmd}() {
            COMPREPLY=()
            local word word="${COMP_WORDS[COMP_CWORD]}"

            if [ "$COMP_CWORD" -eq 1 ]; then
                local commands="$(compgen -W "$(works-alias subcommands #{cmd})" -- "$word")"
                COMPREPLY=( $commands )
            fi
        }

        complete -F _#{cmd} #{cmd}
      BASH
      bash_completion.install bash_complete => bash_complete
    end
  end
  
  def caveats
    <<~EOS

     설치후 다음 명령어를 터미널에서 실행:
        works-alias install

    EOS
  end
end
