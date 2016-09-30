require './slideable'
require './piece'

class Rook < Piece
  include Slideable

  attr_reader :symbol, :move_dirs, :color

  def initialize(color, board, pos)
    super
    
    @symbol = :r
    @move_dirs = [[0, -1], [0, 1], [-1, 0], [1, 0]]
  end
end
