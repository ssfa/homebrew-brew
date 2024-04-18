# frozen_string_literal: true
require 'formula'
require_relative './concern'

module Ssfa
  module ThorScriptInstallHelper
    extend Ssfa::Concern

    included do
      homepage(Dir.chdir(__dir__) { url = `git remote get-url origin`.strip; /https/ =~ url ? url : "https://github.com/#{url.split('.com:').last}" })
      url Dir.chdir(__dir__) { `git remote get-url origin`.strip }, using: :git, branch: 'main'

      depends_on 'ruby@3.2'
    end

    def install
      install_command
    end

    def install_command
      require 'pathname'
      ENV['GEM_HOME'] = libexec
      system("gem install --no-document thor")

      command = name
      source = Pathname.glob(File.expand_path("../../../scripts/#{command}*", __FILE__)).first
      FileUtils.cp source, command
      FileUtils.chmod 'u+x', command
      bin.install command
      bin.env_script_all_files(libexec / "bin", GEM_HOME: libexec)

      install_zsh_completion(command)
      install_bash_completion(command)
    end

    # @return Array<String, String> command, describe
    def thor_commands(command)
      shell = !`which zsh`.empty? ? 'zsh' : 'bash'
      `#{shell} #{bin / command}`
        .lines.map(&:strip)
        .reject { |i| /^#{command} help/ =~ i }
        .select { |i| /^#{command} \S+/ =~ i }
        .map { |i| i.gsub(/^#{command}/, '').split(/\s+#/) }
    end

    def install_zsh_completion(command)
      shell = !`which zsh`.empty? ? 'zsh' : 'bash'

      _completion = "_#{command}"

      if `#{shell} #{bin / command}`.include?('zsh-completion')
        File.open(_completion, 'w') { |f| f.write("eval \"$(#{command} zsh-completion)\"") }
      else
        File.open(_completion, 'w') { |f| f.write(<<~ZSH) }
          #compdef #{command}
          #autoload
          _#{command}() {
            local commands
            commands=(#{thor_commands(command).map { |i| (i * ':').strip.inspect } * " "})
            if (( CURRENT == 2 )); then
              _alternative \\
                'commands:: _describe -t commands "#{command} commands" commands'
            fi
            return
          }
          _#{command}
        ZSH
      end
      zsh_completion.install _completion
    end

    def install_bash_completion(command)
      bash_complete = "#{command}.bash"
      File.open(bash_complete, 'w') { |f| f.write(<<~BASH) }
        #!/usr/bin/env bash

        _#{command}() {
            COMPREPLY=()
            local word
            word="${COMP_WORDS[COMP_CWORD]}"

            if [ "$COMP_CWORD" -eq 1 ]; then
                local commands="$(compgen -W "#{thor_commands(command).map { |i| i[0] } * " "}" -- "$word")"
                COMPREPLY=( $commands )
            fi
        }

        complete -F _#{command} #{command}
      BASH
      bash_completion.install bash_complete
    end
  end
end