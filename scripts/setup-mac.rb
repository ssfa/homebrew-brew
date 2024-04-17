#!/usr/bin/env ruby

require 'thor'
require 'rainbow'
require 'pathname'
require 'time'
require 'fileutils'
require 'rouge'

TS = Time.now
module SetupMac
  module Helper
    ENV_APPS = Set[*%w[direnv nodenv rbenv pyenv pyenv-virtualenv]].to_a
    CUI_APPS = Set[*%w[coreutils git ripgrep fzf gh jq bat rb features tldr starship git-flow-avh gitmoji git-lfs openjdk colordiff kubernetes-cli kube-score k9s]].to_a

    CASK_APPS = {
      # uncategory
      'docker' => 'docker desktop',
      'notion' => 'Notion 데스크탑',
      'iterm2' => '가장 많이 쓰이는 터미널 소프트웨어',
      'dash' => '개발자 문서 도구',
      'bloomrpc' => 'grpc client',
      'altair-graphql-client' => 'Grpahql client',
      'insomnia' => 'rest client',
      'google-drive' => 'Google Drive',
      '1password' => '1password',
      # browser
      'google-chrome' => '크롬',
      'firefox' => '파폭',
      # editor
      'jetbrains-toolbox' => 'jetbrains 툴 설치 및 업데이트 관리',
      'visual-studio-code' => 'Visual Studio Code',
      'microsoft-office' => 'MS Office',
      # windows util
      'alt-tab' => 'Windows-like alt-tab',
      'hiddenbar' => 'Utility to hide menu bar items',
      'amethyst' => 'Automatic tiling window manager similar to xmonad',
      'rectangle' => 'Move and resize windows using keyboard shortcuts or snap areas',
      # bar util
      'itsycal' => 'calendar',
      'keepingyouawake' => 'Tool to prevent the system from going into sleep mode',
      'monitorcontrol' => '외장 모니터 밝기 조절, 볼륨 조정',
      # chat
      'discord' => 'Voice and text chat software',
      'mattermost' => 'Open-source, self-hosted Slack-alternative',
    }

    CASK_VERSION_APPS = {
      'google-chrome-beta' => '크롬',
    }

    FONTS = Set[
      'homebrew/cask-fonts/font-d2coding',
      'homebrew/cask-fonts/font-jetbrains-mono',
      'homebrew/cask-fonts/font-fira-code-nerd-font',
      'homebrew/cask-fonts/font-monaspace',
      'homebrew/cask-fonts/font-monaspace-nerd-font',
    ].to_a

    GUI_APPS = CASK_APPS.keys

    def run(cmd)
      system(cmd.tap { |o| puts Rainbow(o).yellow })
    end

    def mas_signin?
      !`! mas account > /dev/null && echo ' no account '`.include?(' no account ')
    end

    def brew?
      `command -v brew > /dev/null && echo ' exists '`.include?(' exists ')
    end

    def ts
      TS
    end

    def rename_file_if_exists(target)
      if File.exist?(target)
        puts Rainbow("[backup] #{target} => #{target}.#{ts.to_i}").aqua
        FileUtils.mv target, "#{target}.#{ts.to_i}"
      end
    end

    def install_home(filename)
      source = Pathname.new(`brew --prefix setup-mac`.strip) / ' share ' / filename
      target = Pathname.new(Dir.home) / filename
      rename_file_if_exists(target)
      FileUtils.cp source, target
    end

    def brew_apps
      @brew_apps ||= `brew list`.split.compact
    end

    def mas_apps
      @mas_apps ||= `mas list`.lines.map(&:split).map(&:first)
    end

    def remain_apps
      {
        env: {
          template: "미설치된 개발 환경앱이 발견되었습니다. %s 설치하시겠습니까? [Y/n]",
          remain: ENV_APPS - brew_apps,
          install_template: "brew install %s",
        },
        cui: {
          template: "미설치된 개발 환경앱이 발견되었습니다. %s 설치하시겠습니까? [Y/n]",
          remain: CUI_APPS - brew_apps,
          install_template: "brew install %s",
        },
        gui: {
          template: "미설치된 개발 GUI 앱이 발견되었습니다. %s 설치하시겠습니까? (brew 외 방법으로 설치된 경우는 해당 앱만 실패합니다.) [Y/n]",
          remain: GUI_APPS - brew_apps,
          install_template: "brew install --cask %s",
        },
        fonts: {
          template: "미설치된 폰트가 발견되었습니다. %s 설치하시겠습니까? [Y/n]",
          remain: FONTS.reject { |i| brew_apps.include?(i.split('/').last) },
          install_template: "brew install %s",
        },
      }.reject { |_, v| v[:remain].empty? }
    end

  end

  class CLI < Thor
    include Helper
    Error = Class.new(StandardError)

    desc "env", "디버깅용으로, 환경을 출력 한다."

    def env
      ruby_env = {
        RUBY_VERSION: RUBY_VERSION,
        RUBY_PLATFORM: RUBY_PLATFORM,
        RUBY_ENGINE: RUBY_ENGINE }
      key_length = ENV.keys.max_by { |i| i.size }.size
      ENV.to_h.merge(ruby_env)
         .to_a.sort_by { |i| i.to_s }.each { |k, v| puts "#{Rainbow(k.to_s.rjust(key_length + 2)).green}: #{v}" }
    end

    desc "setup_terminal", "zinit 을 설치하고, .zshrc 세팅한다."

    def setup_terminal
      unless brew?
        puts "먼저 Brew 를 설치해주세요."
        run("open https://brew.sh/")
        exit 1
      end

      run "brew install -q zinit"
      run "mkdir -p ~/.zinit"
      # run "ln -sf #{Pathname.new(`brew --prefix zinit`.strip) / ' libexec ' / ' zinit '}  ~/.zinit/bin"

      installed = `brew list`.split
      installs = (ENV_APPS + CUI_APPS - installed)
      installs.each { |i| run "brew install #{i}" }
      run "brew install --HEAD goenv"
      installs.include?(' gitmoji ') && run("NODE_TLS_REJECT_UNAUTHORIZED=0 gitmoji -l > /dev/null 2>&1")

      %w[.zshrc .vimrc].each { |i| install_home(i) }

      doctor "env"
      doctor "cui"

      puts Rainbow("새로운 터미널을 열어주세요.").yellow
    end

    desc "install_gui_apps", "업무에 필요한 기본 mac gui 프로그램들을 설치한다."

    def install_gui_apps
      GUI_APPS.each { |i| run "brew install --cask %s" % i }
      CASK_VERSION_APPS.each { |i| run "brew install --cask /homebrew/cask-versions/%s" % i }
      FONTS.each { |i| run "brew install %s" % i }
      doctor "gui"
    end

    desc "hint", "문제에 대한 힌트"

    def hint
      puts <<~EOF
        # 자동완성 권한 관련 메세지가 나오면 다음을 실행한다.
        # zsh compinit: insecure directories, run compaudit for list.
        compaudit | xargs chmod g-w
      EOF
    end

    desc "readme", "도구에 대한 설명"

    def readme
      readme = Pathname.new(`brew --prefix setup-mac`.strip) / ' share ' / ' setup - mac.readme.md '
      contents = readme.read

      formatter = Rouge::Formatters::Terminal256.new
      lexer = Rouge::Lexers::Markdown.new
      puts formatter.format(lexer.lex(contents))
    end

    desc "doctor", "문제점 검출"

    def doctor(categories = nil)
      puts Rainbow("환경을 확인합니다.").yellow if categories.nil?
      categories ||= remain_apps.keys.map(&:to_s)

      remain_apps.select { |k, _| categories.include?(k.to_s) }.each do |_, v|
        apps = v[:remain]
        puts v[:template] % (apps * ', ')
        apps.each { |i| run(v[:install_template] % i.to_s) } if STDIN.gets.downcase.strip.then { |o| ['y', ''].include? o }
      end
    end

  end
end

begin
  SetupMac::CLI.start
rescue SetupMac::CLI::Error => err
  puts "ERROR: #{err.message}"
  exit 1
end

