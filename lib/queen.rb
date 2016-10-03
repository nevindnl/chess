require_relative 'slideable'
require_relative 'piece'

class Queen < Piece
  include Slideable
	
  def initialize(color:, board:, pos:)
    super

    @symbol = :q
    @move_dirs = [
      [0, -1], [0, 1], [-1, 0], [1, 0],
      [-1, -1], [1, 1], [-1, 1], [1, -1]
    ]
  end
end
