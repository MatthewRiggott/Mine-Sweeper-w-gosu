require 'pry'

class Minefield
  attr_reader :row_count, :column_count

  def initialize(row_count, column_count, mine_count)
    @column_count = column_count
    @row_count = row_count
    @mine_count = mine_count
    #arrays are sized at +2 to prevent searching for neighbors 'off the grid/ at edges' causing an error
    @is_mine = Array.new(@column_count+2) { |i| Array.new(@row_count+2) { |j| false } }
    @clicked = Array.new(@column_count+2) { |i| Array.new(@row_count+2) { |j| false } }
    (0..column_count+1).each {|c| @clicked[c][0], @clicked[c][@row_count+1] = true, true}
    (0..row_count+1).each {|r| @clicked[0][r], @clicked[@column_count+1][r] = true, true}
    place_mines(mine_count)
  end

  def place_mines(mines)
    count_mines = 1
    loop do
      break if count_mines > mines
      x = (1..@column_count).to_a.sample
      y = (1..@row_count).to_a.sample
      count_mines += 1 if !@is_mine[x][y]
      @is_mine[x][y] = true
    end
  end

  # Return true if the cell been uncovered, false otherwise.
  def cell_cleared?(row, col)
    @clicked[row][col]
  end

  # Uncover the given cell. If there are no adjacent mines to this cell
  # it should also clear any adjacent cells as well. This is the action
  # when the player clicks on the cell.
  def clear(row, col)
    @clicked[row][col] = true
    count = adjacent_mines(row, col)
    if count == 0
      neighbors = get_neighbors(row, col)
      neighbors.each do |adj|
        x, y = adj[0], adj[1]
        if @clicked[x][y] == false
          clear(x, y)
        end
      end
    end
    return count
  end

  # Check if any cells have been uncovered that also contained a mine. This is
  # the condition used to see if the player has lost the game.
  def any_mines_detonated?
    (1..@row_count).each do |x|
      (1..@column_count).each do |y|
        return true if @clicked[x][y] && @is_mine[x][y]
      end
    end
    return false
  end

  # Check if all cells that don't have mines have been uncovered. This is the
  # condition used to see if the player has won the game.
  def all_cells_cleared?
    win_count = @row_count * @column_count - @mine_count
    count_clicked = 0
    (1..@row_count).each do |x|
      (1..@column_count).each do |y|
        count_clicked += 1 if @clicked[x][y] && !@is_mine[x][y]
      end
    end
    return count_clicked == win_count
  end

  # Returns the number of mines that are surrounding this cell (maximum of 8).
  def get_neighbors (row, col)
    neighbors = []
    (-1..1).each do |x|
      (-1..1).each do |y|
        neighbors << [x+row, y+col] unless x == 0 && y == 0
      end
    end
    neighbors
  end

  def adjacent_mines(row, col)
    neighbors = get_neighbors(row, col)
    count = 0
    neighbors.each do |cell|
      count += 1 if contains_mine?(cell[0], cell[1])
    end
    return count
  end

  # Returns true if the given cell contains a mine, false otherwise.
  def contains_mine?(row, col)
    return @is_mine[row][col]
  end
end
