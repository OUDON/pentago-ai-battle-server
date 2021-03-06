require 'open3'
require 'timeout'
require_relative './GameBoard'

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
      self.exit
      raise TimeLimitExceededError
    end
    [res, exec_time]
  end

  def exit
    begin
      STDERR.puts "Kill the Player #{name}'s process"
      Process.kill("KILL", @thread.pid)
      close_pipes
    rescue Errno::ESRCH
      STDERR.puts "The process is already killed"
    end
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

  private
  attr_reader :game_board, :players, :time_limit_max, :time_limits, :logger

  public
  def initialize(players, args)
    @players = players
    @time_limit_max = args.fetch(:time_limit, 60 * 1000) # (ms)
    @time_limits = Array.new(2, time_limit_max)
    @game_board = GameBoard.new
    @in_progress = false

    if args[:log]
      @logger = File.open(args[:log], "w")
    else
      @logger = STDOUT
    end
  end

  def start
    logger.puts <<~EOT
      # Battle Information
      Player1: #{players[0].name}
      Player2: #{players[1].name}
      Time:    #{time_limit_max}

    EOT

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
    logger.puts "# Battle Log"
    @move_history = []

    while in_progress?
      play_turn
    end
  end

  def in_progress?
    @in_progress && game_board.in_progress?
  end

  def exit
    @players.each do |player|
      player.exit
    end
  end

  private
  def play_turn
    turn             = game_board.turn
    turn_player_idx  = game_board.turn_player_idx
    turn_player      = players[turn_player_idx]

    time_limit = time_limits[turn_player_idx]
    game_info = <<~EOT
      #{turn}
      #{time_limit}
      #{game_board}
    EOT

    STDERR.puts "Send the game informations to Player #{turn_player.name}"
    STDERR.puts game_info
    STDERR.puts ""

    begin
      move, time = turn_player.communicate(game_info, time_limit)
      time_limits[turn_player_idx] -= time
      raise PlayerProcess::TimeLimitExceededError if time_limits[turn_player_idx] <= 0
    rescue PlayerProcess::TimeLimitExceededError
      STDERR.puts "Player #{turn_player.name}: Time Limit Exceeded"
      game_end(turn_player_idx^1, "(Player #{turn_player.name}: Time Limit Exceeded)")
      return
    end

    move = move.chomp
    @move_history << move
    begin
      result = game_board.move(*move.split.map(&:to_i))
    rescue GameBoard::InvalidMoveError
      STDERR.puts "Player #{turn_player.name}: Invalid Move"
      game_end(turn_player_idx^1, "(Player #{turn_player.name}: Invalid Move \"#{move}\")")
      return
    end

    logger.puts <<~EOT
      Turn #{turn}: #{players[turn_player_idx].name} [#{game_board.turn_player_symmbol}]
      Move: #{move}
      #{game_board}

    EOT

    if result
      if result == GameBoard::Result::DRAW
        game_end(-1, "Draw")
      else
        winner = result-1
        game_end(winner, "(Player #{players[winner].name}: Got five stones in a row)")
      end
    end
  end

  def game_end(winner, reason)
    logger.puts <<~EOT
      # Moves
      #{@move_history.join("\n")}

    EOT

    if winner != -1
      logger.puts <<~EOT
        # Result
        Winner: #{players[winner].name}
        #{reason}
      EOT
    else
      logger.puts <<~EOT
        #Result
        Draw
      EOT
    end
    @in_progress = false
  end
end


if __FILE__ == $0
  gm = GameManager.new(
    [PlayerProcess.new("Alice", "./ai_sample.out"),
     PlayerProcess.new("Bob",   "./ai_sample.out")]
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
