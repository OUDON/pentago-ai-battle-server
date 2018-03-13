require 'open3'
require 'timeout'
require './GameBoard'

class PlayerProcess
  attr_reader :name

  class TimeLimitExceededError < RuntimeError; end

  def initialize(name, cmd)
    @name = name
    @stdin, @stdout, @stderr, @thread = Open3.popen3(cmd)
    @thread.freeze
  end

  def send_initial_info(init_info)
    writeline(init_info)
  end

  def communicate(game_info, time_limit)
    res, exec_time = nil, nil
    timeout_val = time_limit * 1.1 / 1000.0
    begin
        writeline(game_info)
        start_at = Time.now
        Timeout.timeout(timeout_val) {
          res = readline
        }
        exec_time = ((Time.now - start_at) * 1000).to_i
    rescue Timeout::Error
      STDERR.puts "Player #{name}: Time Limit Exceeded (#{time_limit} sec)"
      Process.kill("KILL", @thread.pid)
      close_pipes
      # TODO: Raise an error
    end
    [res, exec_time]
  end

  private
  def readline
    @stdout.gets
  end

  def writeline(str)
    @stdin.puts str
    @stdin.flush
  end

  def close_pipes
    [@stdin, @stdout, @stderr].each do |pipe|
      pipe.close
    end
  end
end


class GameManager
  BOARD_WIDTH  = 6
  BOARD_HEIGHT = 6
  TIME_LIMIT   = 60 * 1000 # (ms)

  private
  attr_reader :game_board, :players, :time_limits

  public
  def initialize(players)
    @players = players
    @time_limits = Array.new(2, TIME_LIMIT)
    @game_board = GameBoard.new
    @in_progress = false
  end

  def start
    @players.each_with_index do |player, i|
      init_info = [BOARD_WIDTH, BOARD_HEIGHT, i].join("\n")

      STDERR.puts "Send the initial informations to Player #{player.name}:"
      STDERR.puts init_info
      STDERR.puts ""

      player.send_initial_info(init_info)
    end
    @in_progress = true
  end

  def play
    while in_progress?
      play_turn
    end
  end

  def in_progress?
    @in_progress && game_board.in_progress?
  end

  private
  def play_turn
    turn       = game_board.turn
    player_idx = game_board.turn_player_idx

    time_limit = time_limits[player_idx]
    game_info = <<~EOT
      #{turn}
      #{time_limit}
      #{game_board}
    EOT

    STDERR.puts "Send the game informations to Player #{players[player_idx].name}"
    STDERR.puts game_info
    STDERR.puts ""

    move, time = players[player_idx].communicate(game_info, time_limit)
    time_limits[player_idx] -= time

    if time_limits[player_idx] <= 0
      game_end(player_idx^1, "Time Limit Exceeded")
      return
    end

    game_board.move(*move.split.map(&:to_i))

    STDOUT.puts <<~EOT
      Turn #{turn}: #{players[player_idx].name} [#{game_board.turn_player_symmbol}]
      Move: #{move.chomp}
      #{game_board}

    EOT
  end

  def game_end(winner, reason)
    puts "Winner: #{players[winner].name}"
    @in_progress = false
  end
end


if __FILE__ == $0
  gm = GameManager.new(
    [PlayerProcess.new("Alice", "./ai_sample.out"),
     PlayerProcess.new("Bob",   "./ai_sample.out")]
  )
  gm.start
  gm.play
end
