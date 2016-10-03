require_relative 'steppable'
require_relative 'piece'

class King < Piece
  include Steppable
	attr_accessor :unmoved

  def initialize(color:, board:, pos:)
    super

    @symbol = :K
    @move_dirs = [
      [-1, -1], [1, 1], [-1, 1], [1, -1],
      [0, 1], [0, -1], [-1, 0], [1, 0]
    ]

		@unmoved = true
  end

	def moves
		castles = []
		if @unmoved
			if @board[[pos[0], 0]].is_a?(Rook) &&
				@board[[pos[0], 0]].unmoved &&
					((pos[1] - 1).downto(1)).all?{|j| @board[[pos[0], j]] == NullPiece.instance} 

				castles << [pos[0], pos[1] - 2]
			elsif @board[[pos[0], 7]].is_a?(Rook) &&
				@board[[pos[0], 7]].unmoved &&
					((pos[1] + 1).upto(6)).all?{|j| @board[[pos[0], j]] == NullPiece.instance}

				castles << [pos[0], pos[1] + 2]
			end
		end

		super + castles
	end
end
