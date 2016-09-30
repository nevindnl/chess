require './slideable'
require './piece'

class Bishop < Piece
  include Slideable

  attr_reader :symbol, :move_dirs, :color

  def initialize(color, board, pos)
    super
    
    @symbol = :b
    @move_dirs = [[-1, -1], [1, 1], [-1, 1], [1, -1]]
  end
end
