require './GameManager'

def main
  if ARGV.size != 4
    puts "Usage: ruby #{$0} NAME1 CMD1 NAME2 CMD2"
    puts "  NAME1 : the first player's name"
    puts "  CMD1  : command to execute the first player's AI client"
    puts "  NAME2 : the second player's name"
    puts "  CMD2  : command to execute the second player's AI client"
    exit(1)
  end

  gm = GameManager.new(
    [PlayerProcess.new(ARGV[0], ARGV[1]),
     PlayerProcess.new(ARGV[2], ARGV[3])]
  )
  gm.start
  gm.play
  gm.exit
end

if __FILE__ == $0
  main
end
