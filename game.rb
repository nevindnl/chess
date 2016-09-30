require './board'
require './player'
require './bishop'
require './rook'
require './king'
require './knight'
require './queen'
require './pawn'

class Game

  attr_reader :white, :black

  def initialize(board = Board.new)
    @board = board
    @board.make_starting_grid

    @white = Player.new(board, :white)
    @black = Player.new(board, :black)

    @current_player = @white
  end

  def swap_player
    @current_player = @current_player == @white ? @black : @white
  end

  def loser
    [:white, :black].find { |color| @board.checkmate?(color) }
  end

  def move
    start_pos = @current_player.command
    end_pos = @current_player.command

    if @board[start_pos].color == @current_player.color
      @board.move(start_pos, end_pos)
    end
  end

  def run
    until loser
      move
      swap_player
    end

    puts "#{loser} loses."
  end

  def rand_move
    @current_player.display.render

    player_pieces =
      if @current_player.color == :white
        @board.white_pieces
      else
        @board.black_pieces
      end

    #keys are piece_pos, values are piece_moves's
    moves = Hash.new

    player_pieces.each do |piece|
      piece_moves = piece.valid_moves

      moves[piece.pos] = piece_moves unless piece_moves.empty?
    end

    captures = {}
    moves.each do |piece_pos, piece_moves|

      piece_captures = piece_moves.select do |move|
        @board[move].color == @current_player.opponent_color
      end

      captures[piece_pos] = piece_captures unless piece_captures.empty?
    end

    moves = captures unless captures.empty?

    start_pos = moves.keys.sample
    end_pos = moves[start_pos].sample

    @board.move(start_pos, end_pos)
  end

  def rand_run
    turns = 0
    until loser || turns > 500
      rand_move
      swap_player

      turns += 1

      sleep(0.1)
    end

    @current_player.display.render
    puts "#{loser} loses."

    loser
  end
end

game = Game.new()
game.run()
