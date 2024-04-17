#!/usr/bin/env ruby

%w[rubygems amazing_print table_print json yaml].each do |i|
  begin
    require i
  rescue LoadError
    # ignored
  end
end

# https://github.com/thisredone/rb

File.join(Dir.home, '.rbrc').tap {|f| load f if File.exist?(f)}

def execute(_, code)
  puts _.instance_eval(&code)
rescue Errno::EPIPE
  exit
end

single_line = ARGV.delete('-l')
code        = eval("Proc.new { #{ARGV.join(' ')} }")
single_line ? STDIN.each {|l| execute(l.chomp, code)} : execute(STDIN.each_line, code)
