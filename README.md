## Chess

Chess, written in Ruby, played in the terminal.

![image of game](./screenshots/game.png)

1. `git clone http://github.com/nevindnl/chess.git`
2. `cd chess`
3. `ruby chess.rb`

## Implementation
### Design
* [NullPiece][nullpiece]
* [Piece][piece]
  * [Slideable][slideable]
    * [Bishop][bishop]
    * [Rook][rook]
    * [Queen][queen]
  * [Steppable][steppable]
    * [Knight][knight]
    * [King][king]
  * [Pawn][pawn]

Each piece stores a list of directions in which they can move. With the exception of the pawn, pieces either include a Slideable or Steppable module that generates a list of possible moves. The Piece superclass then filters these moves into valid moves, depending on whether they move a piece's own side into check.

* [Board][board]
  * Stores board, check/checkmate logic, and scoring logic.
* [Player][player]
* [Game][game]
  * Stores player interaction logic and computer AI.
* [Display][display]
  * Stores presentational logic.

  [nullpiece]: ./lib/nullpiece.rb
  [piece]: ./lib/piece.rb
  [slideable]: ./lib/slideable.rb
  [steppable]: ./lib/steppable.rb
  [pawn]: ./lib/pawn.rb
  [bishop]: ./lib/bishop.rb
  [rook]: ./lib/rook.rb
  [queen]: ./lib/queen.rb
  [knight]: ./lib/knight.rb
  [king]: ./lib/king.rb
  [board]: ./lib/board.rb
  [player]: ./lib/player.rb
  [game]: ./lib/game.rb
  [display]: ./lib/display.rb

### AI

The computer AI uses a minimax algorithm with alpha-beta pruning.

#### Minimax

Minimax is a general decision rule for adversarial games, and the most widely used one in chess. In a two-player zero-sum game like chess, the current player is designated the maximizing player and the opponent is designated the minimizing player. The maximizing player aims to maximize the score and minimizing player aims to minimize the score.

From a set of possible moves, minimax will move to maximize the score at a certain depth in the game tree, assuming that the opponent will always move to minimize the maximum score at that depth. (In zero-sum games, this value is equivalent to the Nash equilibrium.)

The implementation of a minimax algorithm is recursive. If it is the current player's turn (that is, the maximizing player's turn), the maximum of the minimax scores of each of the current player's moves is returned. Else, if it is the opponent's turn (that is, the minimizing player's turn), the minimum of the minimax scores of each of the opponent's moves is returned. The base cases are when a player has lost or when the maximum depth has been reached -- in either case, the score is returned.

#### Alpha-beta pruning

Minimax visits every leaf of the game tree, giving it an time complexity of `O(b ** d)` where b is the branching factor -- that is, the number of possible moves for one player at a time -- and d is the depth.

Alpha-beta pruning is a simple but powerful tool used to prevent unnecessary calculation. Suppose a maximizing player has the choice of two moves `a` and `b`, and the minimax score of choosing `a` is `minimax(a)`. Suppose then that while evaluating the minimizing player's subtree after the maximizing player has chosen `b`, we calculate that the minimizing player can force a score less than `minimax(a)`. Then `minimax(b) < minimax(a)`, so the maximizing player would never choose `b`, so we can stop evaluating the subtree after `b` for the minimizing player. (That is, we can *prune* those branches.)

Similarly, for the minimizing player with the choice of two moves `a'` and `b'`, if we calculate after choosing `b'` that the maximizing player can force a score greater than `minimax(a')`, then `minimax(b') > minimax(a')`, the minimizing player would never choose `b'`, and we can stop evaluating the subtree after `b'` for the maximizing player.

The implementation of alpha-beta pruning is simple: each node calls minimax with two parameters `alpha` and `beta` that represent the best minimax scores already found for the maximizing player and the minimizing player, respectively, starting from that node.

When it is the maximizing player's turn, if a move can force a higher minimax score, `alpha` is updated. When it is the minimizing player's turn, if a move can force a lower minimax score, `beta` is updated.

But, if it is the maximizing player's turn, and a move can force a higher minimax score than `beta`, we can prune the subtree in question because we know that the minimizing player would not allow it to be entered, because the minimizing player can force a better option. Similarly, if it is the minimizing player's turn, and a move can force a lower minimax score than `alpha`, we can prune the subtree in question, because we know that the maximizing player would not allow it to be entered, because the maximizing player also can force a better option.

---

In chess, which has a branching factor of ~35, alpha-beta pruning is essential for a minimax implementation of any depth. Here, the depth is determined by the difficulty of the game, which the user inputs.

```Ruby
# initialize alpha and beta to sentinels
def minimax player: @current_player, board: @board, move: nil, alpha: -400, beta: 400, depth: 0
  # terminate at max depth or if checkmate
  if depth == @difficulty[@current_player.color] || score(board).abs == 300
    return {score: score(board), move: move}
  end

  pieces = player.color == :white ? board.white_pieces : board.black_pieces
  pieces.shuffle!

  best_move = nil

  # current_player maximizes
  if player == @current_player
    best_score = alpha

    # iterate through possible moves
    pieces.each do |piece|
      piece.valid_moves.each do |end_pos|
        # for each move:
        possible_move = [piece.pos, end_pos]

        # create board
        possible_board = board.dup
        possible_board.move(*possible_move)

        # recurse to find best score after move, updating lower bound
        possible_score = minimax(
          player: other_player(player),
          board: possible_board,
          move: possible_move,
          alpha: best_score,
          beta: beta,
          depth: depth + 1
        )[:score]

        # terminate if score is greater than minimizing player would allow
        if possible_score > beta
          return {score: beta, move: nil}
        end

        # update best score
        if possible_score > best_score
          best_score = possible_score
          best_move = possible_move
        end
      end
    end

  # other player minimizes
  else
    best_score = beta

    pieces.each do |piece|
      piece.valid_moves.each do |end_pos|
        possible_move = [piece.pos, end_pos]

        possible_board = board.dup
        possible_board.move(*possible_move)

        # recurse to find best score after move, updating upper bound
        possible_score = minimax(
          player: other_player(player),
          board: possible_board,
          move: possible_move,
          alpha: alpha,
          beta: best_score,
          depth: depth + 1
        )[:score]

        # terminate if score is less than maximizing player would allow
        if possible_score < alpha
          return {score: alpha, move: nil}
        end

        if possible_score < best_score
          best_score = possible_score
          best_move = possible_move
        end
      end
    end
  end

  {score: best_score, move: best_move}
end
```

If checkmate, the score is a sentinel value. Else, it is the difference of the weighted piece counts, with a possible check bonus.

```Ruby
# Game#score
def score board
  board.score(@current_player.color)
end
```
```Ruby
# Board#score
def score color
  other_color = color == :white ? :black : :white

  # if checkmate, return sentinel
  if checkmate? color
    -300
  elsif checkmate? other_color
    300
  else
    # else, return check bonus
    check =
      if in_check? color
       -10
      elsif in_check? other_color
        10
      else
        0
      end

    # plus difference of weighted piece counts
    check + weighted_piece_count(color) - weighted_piece_count(other_color)
  end
end

def weighted_piece_count color
  pieces(color).inject(0) do |score, piece|
    if piece.is_a? Pawn
      score + 2
    elsif piece.is_a? Knight
      score + 7
    elsif piece.is_a? Bishop
      score + 8
    elsif piece.is_a? Rook
      score + 12
    elsif piece.is_a? Queen
      score + 20
    else
      score
    end
  end
end
```
