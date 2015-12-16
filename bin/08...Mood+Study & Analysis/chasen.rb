#! ruby -Ks
require 'Win32API'                      # (1)
require 'nkf'

module Chasen                           # (2)
  DLL = 'chasen.dll'
  Setarg  = Win32API.new(DLL, 'set_argument_parameters', 'ip', 'i')
  Analyze = Win32API.new(DLL, 'analyze','p', 'p')

  def setarg(*opt)                      # (3)
    argc = opt.size + 1
    argv = opt.unshift($0).push(nil).pack('p' * opt.size)
    Setarg.call(argc, argv)
  end

  def analyze(text)                     # (4)
    text = NKF::nkf('-XSs', text)
    Analyze.call(text + 0.chr)
  end

  module_function :setarg, :analyze     # (5)
end

if $0 == __FILE__                       # (6)

  Chasen::setarg('-F%m %P-\n');

  while line = gets do
    line.chomp!
    break if line.empty?
    puts(Chasen::analyze(line))
  end
end
