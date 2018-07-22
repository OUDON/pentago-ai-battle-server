require "set"

class GameBoard
  attr_reader :cells
  
  BOARD_SIZE = 6
  BOARD_SIZE_HALF = BOARD_SIZE / 2
  TARGET_NUM = 5

  module CellItem 
    EMPTY = 0
    BLACK = 1
    WHITE = 2
  end
  CellItem.freeze

  CELL_ITEM_SYMBOLS = {
    CellItem::EMPTY => "-",
    CellItem::BLACK => "o",
    CellItem::WHITE => "x",
  }.freeze

  module RotateDir
    LEFT  = 0
    RIGHT = 1
  end
  RotateDir.freeze

  module Result
    DRAW      = 0
    WIN_BLACK = 1
    WIN_WHITE = 2
  end
  Result.freeze

  class InvalidMoveError < RuntimeError; end

  def initialize
    @cells = Array.new(BOARD_SIZE) { Array.new(BOARD_SIZE, CellItem::EMPTY) }
    @turn = 0
    @empty_cell_num = BOARD_SIZE * BOARD_SIZE
  end

  def move(put_x, put_y, rot_idx, rot_dir)
    put(put_x, put_y)
    winner = judge
    return winner if winner

    rotate(rot_idx, rot_dir)
    winner = judge
    return winner if winner

    next_turn
    nil
  end

  def turn
    @turn + 1
  end

  def turn_player
    @turn%2 == 0 ? CellItem::BLACK : CellItem::WHITE
  end

  def turn_player_idx
    @turn%2
  end

  def turn_player_symmbol
    CELL_ITEM_SYMBOLS[turn_player]
  end

  def in_progress?
    winner = judge
    @empty_cell_num > 0 && !winner
  end

  def to_s
    board_str = cells.map { |row| row.map { |cell| CELL_ITEM_SYMBOLS[cell] }.join }
    board_str.join("\n")
  end

  def dump
    puts "==============="
    puts "Turn  : #{turn}"
    puts "Player: #{CELL_ITEM_SYMBOLS[turn_player]}"
    puts "#{self}"
  end

  private
  def next_turn
    @turn += 1
  end

  def put(x, y)
    raise InvalidMoveError if !valid_point?(x, y) || cells[y][x] != CellItem::EMPTY
    cells[y][x] = turn_player
    @empty_cell_num -= 1
  end

  def rotate(idx, dir)
    if !idx.between?(0, 3)
      raise InvalidMoveError
    end

    idx_x, idx_y = idx % 2, idx / 2
    tmp_cells = Array.new(BOARD_SIZE_HALF) { Array.new(BOARD_SIZE_HALF, CellItem::EMPTY) }
    (0...BOARD_SIZE_HALF).each do |y|
      (0...BOARD_SIZE_HALF).each do |x|
        tmp_cells[y][x] = cells[idx_y * BOARD_SIZE_HALF + y][idx_x * BOARD_SIZE_HALF + x]
      end
    end

    if dir == RotateDir::LEFT
      tmp_cells = rotate_left(tmp_cells)
    elsif dir == RotateDir::RIGHT
      tmp_cells = rotate_right(tmp_cells)
    else
      raise InvalidMoveError
    end

    (0...BOARD_SIZE_HALF).each do |y|
      (0...BOARD_SIZE_HALF).each do |x|
        cells[idx_y * BOARD_SIZE_HALF + y][idx_x * BOARD_SIZE_HALF + x] = tmp_cells[y][x]
      end
    end
  end

  def rotate_left(tmp_cells)
    tmp_cells.map(&:reverse).transpose
  end

  def rotate_right(tmp_cells)
    tmp_cells.transpose.map(&:reverse)
  end

  def judge
    winners = Set.new
    filled  = true
    (0...BOARD_SIZE).each do |y|
      (0...BOARD_SIZE).each do |x|
        filled = false if cells[y][x] == CellItem::EMPTY
        color = judge_at(x, y)
        winners.add(color) if color != nil
      end
    end

    if winners.size == 1
      return winners.to_a[0]
    elsif winners.size == 2 || filled
      return Result::DRAW
    else
      return nil
    end
  end

  def judge_at(x, y)
    if cells[y][x] == CellItem::EMPTY
      return nil
    end

    color = cells[y][x]
    dxs, dys = [1, 0, 1, -1], [0, 1, 1, 1]
    dxs.zip(dys).each do |dx, dy|
      cnt = 1
      tx, ty = x, y
      (1..TARGET_NUM).each do
        tx += dx
        ty += dy
        break if !valid_point?(tx, ty) || cells[ty][tx] != color
        cnt += 1
      end
      return color if cnt == TARGET_NUM
    end

    nil
  end

  def valid_point?(x, y)
    x.between?(0, BOARD_SIZE-1) && y.between?(0, BOARD_SIZE-1)
  end
end


if __FILE__ == $0
  board = GameBoard.new
  loop do
    board.dump

    put_x, put_y, rot_idx, rot_dir = gets.split.map(&:to_i)
    begin
      winner = board.move(put_x, put_y, rot_idx, rot_dir)
    rescue GameBoard::InvalidMoveError
      puts "Invalid input."
    ensure
      if winner
        board.dump
        puts "Player #{winner} win!"
        break
      end
    end
  end

  # board.move(1, 0, 0, GameBoard::RotateDir::LEFT)
  # board.move(1, 0, 0, GameBoard::RotateDir::LEFT)
  # board.move(4, 4, 3, GameBoard::RotateDir::RIGHT)
  # board.move(3, 4, 3, GameBoard::RotateDir::RIGHT)
end
