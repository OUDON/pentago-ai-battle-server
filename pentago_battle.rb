require './GameManager'

def argparse
  require 'optparse'
  args = {}
  o = OptionParser.new do |opts|
    opts.banner = [
      "Usage: ruby #{$0} [options] NAME1 CMD1 NAME2 CMD2",
      "  NAME1 : the first player's name",
      "  CMD1  : command to execute the first player's AI client",
      "  NAME2 : the second player's name",
      "  CMD2  : command to execute the second player's AI client",
      "",
      "options:",
    ].join("\n")

    opts.on("-t", "--time TIME", "Muximum time to compute (ms)") { |val| args[:time_limit] = val.to_i }
    opts.on("--log FILE", "Logging a battle to the FILE (default: STDOUT)") { |val| args[:log] = val.to_s }

    begin
      opts.parse!
    rescue OptionParser::InvalidOption => e
      STDERR.puts [opts, e].join("\n")
      exit(1)
    end
  end
  [args, o]
end

def main
  args, opts = argparse
  if ARGV.size != 4
    STDERR.puts opts
    exit(1)
  end

  gm = GameManager.new(
    [PlayerProcess.new(ARGV[0], ARGV[1]), PlayerProcess.new(ARGV[2], ARGV[3])],
    args
  )
  gm.start
  begin
    gm.play
  rescue Interrupt
    gm.exit
    exit(1)
  end

  gm.exit
end

if __FILE__ == $0
  main
end
