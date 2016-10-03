module Slideable
  def moves
    row, col = @pos
    all_moves = []

    @move_dirs.each do |move_dir|
      delta_row, delta_col = move_dir

      (1..7).each do |distance|
        new_row = row + delta_row * distance
        new_col = col + delta_col * distance

        # break unless in bounds and does not have a piece of the same color
        break unless @board.in_bounds?([new_row, new_col]) &&
          @board[[new_row, new_col]].color != @color

        all_moves << [new_row, new_col]

        # break if opponent's color - captured!
        break if @board[[new_row, new_col]].color == @opponent_color
      end
    end

    all_moves
  end
end
