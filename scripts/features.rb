#!/usr/bin/env ruby

require 'thor'
require 'rainbow'
require 'pathname'
require 'fileutils'
require 'erb'
require 'json'

module Features
  module Helper
    LIMIT = 100
    SIZE_PER_CALL = 25

    def paint_assignees(assignees)
      assignees ||= []
      " #{assignees.map { |i| Rainbow("@#{i['login']}").cyan } * ',' }" unless assignees.empty?
    end

    def paint_labels(labels)
      labels ||= []
      " [#{labels.map { |l| Rainbow(l['name']).color(l['color']) } * ","}]" unless labels.empty?
    end

    def paint_state(state) = state.gsub(/OPEN/, Rainbow(' open').green).gsub('CLOSED', Rainbow(' closed').red)

    def make_title(issue, state: true)
      issue && <<~TITLE.strip
        #{Rainbow("##{issue[:number]}").green} #{issue[:title]}#{paint_labels(issue[:labels])}#{paint_assignees(issue[:assignees])}#{paint_state(issue[:state]) if state}
      TITLE
    end

    def default_limit = (ENV['FEATURES_ISSUE_LIMIT'] || LIMIT).to_i

    def find_issues(issue_numbers = [], state: 'all', limit: default_limit)

      logic = lambda do |numbers, size_per_call|
        cmds = begin
                 open_cmd, closed_cmd = %w(open closed).map { %(gh issue list -s #{_1} --search "is:issue #{numbers * ' '}" -L #{size_per_call} --json number,title,labels,assignees,state 2> /dev/null) }
                 case state
                 when 'open' then [open_cmd]
                 when 'closed' then [closed_cmd]
                 else
                   [open_cmd, closed_cmd]
                 end

               end

        cmds.map { `#{_1}` }
            .map { JSON.parse(_1) }
            .map { _1.to_h { |i| [i['number'].to_s, i.transform_keys { |j| j.to_sym }] } }
            .inject(:merge)
      end

      if issue_numbers.empty?
        logic.call([], limit)
      else
        Array(issue_numbers).uniq.take(limit.to_i).each_slice(SIZE_PER_CALL).map { |numbers| logic.call(numbers, SIZE_PER_CALL) }.inject({}) { |m, o| m.merge(o) }
      end
    end

    def issue_num_from_branch(branch)
      %r{(feature|issue)(|s)/(?<issue_num>\d+)} =~ branch
      issue_num
    end

    def load_issues_from_branches(branches, state: 'all')
      issue_numbers = branches.map(&method(:issue_num_from_branch)).compact
      self.issues = find_issues(issue_numbers, state: state)
    end

    def git_root = @git_root ||= Pathname.new('.').expand_path.ascend.find { |i| i && (i / '.git').exist? }

    def issue_title_path = @issue_title_path ||= git_root / '.issue_title'

    def issue_title
      `git branch --show-current`
        .lines.map(&:strip)
        .tap(&method(:load_issues_from_branches))
        .map { |branch| issues[issue_num_from_branch(branch)] }
        .map { |issue| make_title(issue) }.first
    end
  end

  class CLI < Thor
    include Helper
    Error = Class.new(StandardError)

    attr_accessor :issues

    desc "env", "??????????????????, ????????? ?????? ??????."

    def env
      ruby_env = {
        RUBY_VERSION: RUBY_VERSION,
        RUBY_PLATFORM: RUBY_PLATFORM,
        RUBY_ENGINE: RUBY_ENGINE
      }
      key_length = ENV.keys.max_by { |i| i.size }.size
      ENV.to_h.merge(ruby_env)
         .to_a.sort_by { |i| i.to_s }.each { |k, v| puts "#{Rainbow(k.to_s.rjust(key_length + 2)).green}: #{v}" }
    end

    desc "info [limit]", "???????????? ?????? ????????? ????????????. ?????????: open ????????? ?????? (limit ?????? env FEATURES_ISSUE_LIMIT ??? ?????? ?????? ??????)"
    option :remote, type: :boolean, desc: '????????? ????????? ??????'
    option :all, type: :boolean, desc: 'open, close ?????? ?????? ????????????.'
    option :close, type: :boolean, desc: 'close ??? ????????? ????????????.'

    def info(limit = default_limit)
      state =
        case
        when options[:all] then 'all'
        when options[:closed] then 'closed'
        else 'open'
        end

      `git branch#{" -a" if options[:remote]}`
        .lines.map(&:strip).select(&method(:issue_num_from_branch))
        .tap { |branches| load_issues_from_branches(branches, state: state) }
        .map { |branch| [issues[issue_num_from_branch(branch)], branch.gsub(/^remotes\/origin\//, '')] }
        .select { |issue, _| issue }
        .take(limit.to_i)
        .then { |o| o.size == 0 ? nil : o }
        &.tap do |o|
        max = o.max_by { |_, i| i.size }[1].size
        o.map { |issue, branch| "#{Rainbow(branch.rjust max).yellow} #{make_title(issue)}".strip }.each { |i| puts i }
      end
    end

    desc "clean", "closed ??? ?????? ?????? ???????????? ????????????."

    def clean
      features = `git branch`.lines.map(&:strip).tap(&method(:load_issues_from_branches)).map do |branch|
        issue_num = issue_num_from_branch(branch)
        [branch, issues[issue_num]]
      end.select { |_, i| i }.select { |_, i| i[:state] == 'CLOSED' }

      puts '????????? ?????? ???????????? ????????????.' or exit 1 if features.empty?

      features.each { |branch, issue| puts "    #{Rainbow(branch.rstrip).yellow} #{make_title(issue)}" }

      if !features.empty? && ask("\n?????? ?????? ?????? ???????????? ????????????????", limited_to: %w(y n)) == 'y'
        features.each do |branch, issue|
          puts "?????? => #{branch} #{make_title(issue)}"
          system("git branch -D #{branch}".tap { |i| puts Rainbow(i).yellow })
        end
      end
    end

    desc "init [zsh,bash]", "shell ????????? ?????? alias ????????? ????????????."
    long_desc <<~LONG_DESC
      ?????? features ??? ????????? ???????????? ????????? ????????????.

      Dependencies : fzf

      Install:
      \x5    eval "$(features init zsh)"

      USAGE:
      \x5    features_aliases
      \x5    f
      \x5    fa
      \x5    fsw
    LONG_DESC

    def init(shell = nil)
      puts <<~BASH unless shell
        #.zshrc, .bashrc ??? ?????? ????????? ????????????.
        eval "$(features init zsh)"
      BASH
      exit 0 unless %w[zsh bash -].include?(shell)

      bash_script = <<~SHELL
        command -v f > /dev/null   || alias f='features info --all $@' 
        command -v fa > /dev/null  || alias fa="features info --remote $@"
        command -v fl > /dev/null  || alias fl="features issue_list $@"
        command -v fsw > /dev/null || alias fsw="git switch \\`features info | fzf --ansi -q open | head -1 | awk '{print \\$1}'\\`"
        command -v ft > /dev/null  || alias ft="features current_issue_title | sed -E 's/ open$//' | tr -d '\\n' | pbcopy"
        fn f_list_aliases() { alias | grep "$*" --color=never | sed -e 's/alias //' -e "s/=/::/" -e "s/'//g" | awk -F "::" '{ printf "\\033[1;36m%15s  \\033[2;37m=>\\033[0m  %-8s\\n",$1,$2}'; }
        fn features_aliaes(){ f_list_aliases features }
      SHELL

      erb = RUBY_VERSION =~ /^2.(4|5)/ ? ERB.new(bash_script, nil, '-') : ERB.new(bash_script, trim_mode: '-')
      puts erb.result(binding)
    end

    desc 'save_issue_title', '.issue_title ??? ?????? ????????? ????????????.'

    def save_issue_title = File.open(issue_title_path, 'w') { |f| f.write issue_title }

    desc 'current_issue_title', '[DEPRECATED] .issue_title ??? ?????? ????????? ????????????. delete after 2021-06'

    def current_issue_title = puts(issue_title)

    desc 'githook', '??????????????? ?????? ?????? ?????? ????????? ???????????? ????????? ????????????.'
    option :remove, aliases: "-r", type: :boolean, desc: 'git hook ??? ?????????.'
    option :remove_all, aliases: "-m", type: :boolean, desc: 'git hook ??? ????????? ?????? ????????? ????????????.'
    option :quite, aliases: "-q", type: :boolean, desc: '???????????? ????????? ???????????? ?????????.'
    long_desc <<~LONG_DESC
      ??????????????? ?????? ?????? ?????? ????????? ???????????? ????????? ????????????.

      Dependencies: direnv, gh cli, starship

      How To: 
      \x5  ??? direnv ??? ???????????? .envrc ?????? STARSHIP_CONFIG (starship.toml) ??????
      \x5  ??? starship ?????????????????? .issue_title ????????? ????????? ?????? ?????? ??????
      \x5  ??? .git/hook/post-checkout ?????? ????????? ????????? features save_issue_title ??? ??????
    LONG_DESC

    def githook
      hook_cmd = "\nfeatures save_issue_title"
      starship = git_root / '.starship.toml'
      post_checkout = git_root / '.git/hooks/post-checkout'
      direnv_cmd = "\nexport STARSHIP_CONFIG=$(PWD)/.starship.toml"
      envrc = git_root / '.envrc'

      # validate
      (STDERR.puts Rainbow("- direnv ????????? ????????????.").red or exit 1) unless envrc.exist?
      (STDERR.puts Rainbow("- starship ????????? ????????????.").red or exit 1) if ENV['STARSHIP_SHELL'].nil?
      (STDERR.puts Rainbow("- git ??????????????? ????????? ????????????.").red or exit 1) if git_root.nil?

      # remove
      if (options[:remove] || options[:remove_all]) && post_checkout.exist?
        puts Rainbow("??? .git/hooks/post-checkout Uninstalled").red
        post_checkout.read.tap { |c| File.open(post_checkout, 'w') { |f| f.write c.sub(hook_cmd, '') } }
      end

      if options[:remove_all]
        puts Rainbow("??? .envrc Uninstalled").red
        envrc.read.tap { |c| File.open(envrc, 'w') { |f| f.write c.gsub(direnv_cmd, '') } } if envrc.exist?

        puts Rainbow("??? .startship.toml deleted").red
        FileUtils.rm_f starship

        puts Rainbow("??? .issue_title deleted").red
        FileUtils.rm_f issue_title_path
      end

      exit unless options.slice('remove_all', 'remove').empty?

      # install
      if starship.exist?
        STDERR.puts Rainbow("- .starship.toml ????????? ???????????????.").red unless options[:quite]
      else
        puts Rainbow("??? .starship.toml Installed").green
        File.open(starship, 'w') { |f| f.write <<~TOML }
          [custom.issue_title]
          format = "\\n[$output]($style)"
          command = "cat $(git rev-parse --show-toplevel)/.issue_title"
          when = "test -s $(git rev-parse --show-toplevel)/.issue_title"
          style = ""
        TOML

        if !envrc.exist? || !envrc.read.include?(direnv_cmd)
          File.open(envrc, 'a') { |f| f.write(direnv_cmd) }
          puts Rainbow("??? .envrc Installed").green
        end
      end

      if post_checkout.exist? && post_checkout.read.include?(hook_cmd)
        STDERR.puts Rainbow("- git hook??? ?????? ???????????? ????????????.").red unless options[:quite]
      else
        File.open(post_checkout, 'a') { |f| f.write(hook_cmd) }
        FileUtils.chmod("+x", post_checkout)
        puts Rainbow("??? .git/hooks/post-checkout Installed").green
      end

      if !issue_title_path.exist? || issue_title_path.read.strip.empty?
        puts Rainbow("??? save .issue_title").green unless options[:quite]
        save_issue_title
      end
    end

    desc 'issue_list [limit]', 'gh i list ?????? ????????? ?????? ?????? ?????? ??????, limit ?????? env FEATURES_ISSUE_LIMIT ??? ?????? ?????? ??????'

    def issue_list(limit = default_limit)
      count = find_issues(state: 'open', limit: limit.to_i).each { |_, issue| puts make_title(issue, state: false) }.count
      puts "Open ?????? ????????? #{limit}??? ????????? ???????????????. ( env FEATURES_ISSUE_LIMIT ??? ???????????????. )" if count == limit
    end

  end

end

begin
  puts <<~HELP if ARGV.empty? || ARGV == ['help']
    features

    ??????
        ????????? ?????? issue/??????, feature/?????? ???????????? gh ??? ???????????? github
        ?????? ????????? ????????????. (???????????? ??????)

    ????????? ??????)
        issue/1    => 1??? ??????
        issue/2-ab => 2??? ??????
        issues/42  => 42??? ??????

    USAGE
        features help info
        features help clean
        features help githook

    SHELL Alias
        echo 'eval "$(features init zsh)"' >> ~/.zshrc
        . ~/.zshrc
        features_aliases

    ENV
       FEATURES_ISSUE_LIMIT : issue_list ?????? ???????????? ?????? ???

  HELP
  Features::CLI.start
rescue Features::CLI::Error => err
  STDERR.puts "ERROR: #{err.message}"
  exit 1
rescue
  STDERR.puts <<~EOS
    Trouble shooting:
      1. ????????? ??????????????? ??????????????????.
      2. github ????????? ?????? ?????? ?????????, ????????? ???????????????. 
        gh auth login
      3. DEBUG=1 ??? ?????? ???????????? ????????? ????????? ???????????????. ( ??? - DEBUG=1 features current_issue_title )
  EOS

  raise $! unless ENV['DEBUG'].nil?
end

