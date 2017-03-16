class Sudoku
  GRID_SIZE = 9

  def initialize
    @grid = Array.new(GRID_SIZE) do
      Array.new(GRID_SIZE) do
        { state: :empty, mutable: true, digit: nil }
      end
    end
  end

  # Handles placing digits on the grid and toggling the state of cells.
  def []=(row, col, digit)
    return unless valid_coordinates?(row, col)
    return unless valid_digit?(digit)
    return unless @grid[row][col][:mutable]

    @grid[row][col][:digit] = digit
    @grid[row][col][:state] = :correct
    toggle_grid_state
  end

  # Used to set up the game and place automatically correct digits.
  def place_start_digit(row, col, digit)
    return unless valid_coordinates?(row, col)
    return unless valid_digit?(digit)

    @grid[row][col] = { state: :correct, mutable: false, digit: digit }
  end

  def [](row, col)
    return unless valid_coordinates?(row, col)
    @grid[row][col]
  end

  private

  def valid_coordinates?(row, col)
    row >= 0 && row < GRID_SIZE && col >= 0 && col < GRID_SIZE
  end

  def valid_digit?(digit)
    digit.between?(1, 9)
  end

  # Used to reset grid to a correct state before checking for conflicts.
  def reset_grid_state_to_correct
    @grid.each do |col|
      col.each do |cell|
        cell[:state] = :correct if cell[:state] == :wrong
      end
    end
  end

  # Used to toggle the state of a cells that may be in conflict.
  def toggle_grid_state
    reset_grid_state_to_correct
    toggle_row_and_column_states
    toggle_subgrid_states
  end

  # Sets the state of a cell if the state is mutable
  def maybe_set_cell_state(row, col, state)
    return unless @grid[row][col][:mutable]
    @grid[row][col][:state] = state
  end

  # Looks at the digit at [row][col] and determines whether
  # that digit has already been seen by checking digit_location_arr.
  # If the digit has been seen, then set the cell state to :wrong, otherwise
  # record the location of the digit.
  def process_cell(digit_location_arr, row, col)
    return unless @grid[row][col][:digit] # skip empty cells

    current_digit = @grid[row][col][:digit]
    # if the current digit already exists somewhere in the list
    if digit_location_arr[current_digit]
      # mark the current cell as wrong
      maybe_set_cell_state(row, col, :wrong)
      # mark the previously found cell as wrong as well
      maybe_set_cell_state(*digit_location_arr[current_digit], :wrong)
    else
      # record the location of this digit
      digit_location_arr[current_digit] = [row, col]
    end
  end

  # Uses two for loops to iterate over both rows and columns at the same time.
  # For each row/column, uses an array to track locations of digits (to determine
  # whether a digit is unique in the row/col and where to find it).
  def toggle_row_and_column_states
    for i in (0...GRID_SIZE)
      digit_locations_row = Array.new(GRID_SIZE + 1, nil)
      digit_locations_col = Array.new(GRID_SIZE + 1, nil)
      for j in (0...GRID_SIZE)
        # note that i and j are swapped in the two calls below
        process_cell(digit_locations_row, i, j)
        process_cell(digit_locations_col, j, i)
      end
    end
  end

  # A subgrid is the set of 9 cells that comprise a block of Sudoku.
  # For each subgrid, uses an array to track the locations of digits (to determine
  # whether a digit is unique in the subgrid and where to find it).
  def toggle_subgrid_states
    for row_offset in [0, 3, 6] do
      for col_offset in [0, 3, 6] do
        digit_locations = Array.new(GRID_SIZE + 1, nil)
        for i in (0..2) do
          for j in (0..2) do
            row = row_offset + i
            col = col_offset + j

            process_cell(digit_locations, row, col)
          end
        end
      end
    end
  end
end
