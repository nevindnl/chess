require_relative "display"

class Player

  attr_reader :display, :color, :opponent_color

  def initialize(board, color)
    @display = Display.new(board)
    @color = color

    @opponent_color = @color == :white ? :black : :white
  end

  def command
    result = nil

    until result
      @display.render
      puts "It is #{@color}'s turn."
      result = @display.get_input
    end

    result
  end
end
