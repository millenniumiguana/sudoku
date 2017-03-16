require './sudoku'

RSpec.describe "Sudoku" do
  context "#initialize" do
    it "creates a @sudoku" do
      @sudoku = Sudoku.new
    end

    it "sets up each cell" do
      @sudoku = Sudoku.new
      for i in (0...9)
        for j in (0...9)
          expect(@sudoku[i, j]).to eq({ state: :empty, mutable: true, digit: nil})
        end
      end
    end
  end

  context "#place_start_digit" do
    it "places a digit at row and col on the board" do
      @sudoku = Sudoku.new
      @sudoku.place_start_digit(3, 4, 5)

      expect(@sudoku[3, 4][:digit]).to eq(5)
    end

    it "automatically marks a digit as correct" do
      @sudoku = Sudoku.new
      @sudoku.place_start_digit(5, 6, 7)

      expect(@sudoku[5, 6][:state]).to eq(:correct)
    end

    it "marks the digit as not mutable" do
      @sudoku = Sudoku.new
      @sudoku.place_start_digit(5, 6, 7)

      expect(@sudoku[5, 6][:mutable]).to be(false)
    end

    it "enforces grid boundaries" do
      @sudoku = Sudoku.new
      @sudoku.place_start_digit(10, 10, 8)

      expect(@sudoku[10, 10]).to eq(nil)
    end

    it "enforces valid digits" do
      @sudoku = Sudoku.new
      @sudoku.place_start_digit(4, 4, 10)

      expect(@sudoku[4, 4][:digit]).to eq(nil)
    end
  end

  context "#[]=" do
    before(:each) do
      @sudoku = Sudoku.new
      @sudoku.place_start_digit(0, 1, 3)
      @sudoku.place_start_digit(0, 5, 5)
      @sudoku.place_start_digit(1, 2, 4)
    end

    it "enforces grid boundaries" do
      @sudoku.place_start_digit(10, 10, 8)

      expect(@sudoku[10, 10]).to eq(nil)
    end

    it "enforces valid digits" do
      @sudoku[4, 4] = 10

      expect(@sudoku[4, 4][:digit]).to eq(nil)
    end

    context "correct digit placement" do
      test_cases = [
        { desc: "top left group", row: 1, col: 1 },
        { desc: "top middle group", row: 2, col: 4 },
        { desc: "top right group", row: 1, col: 8 },
        { desc: "middle left group", row: 5, col: 2 },
        { desc: "middle middle group", row: 5, col: 3 },
        { desc: "middle right group", row: 5, col: 6 },
        { desc: "bottom left group", row: 6, col: 1 },
        { desc: "bottom middle group", row: 7, col: 5 },
        { desc: "bottom right group", row: 8, col: 7 }
      ]

      test_cases.each do |test_case|
        context test_case[:desc] do
          it "should place the digit" do
            @sudoku[test_case[:row], test_case[:col]] = 8
            expect(@sudoku[test_case[:row], test_case[:col]][:digit]).to eq(8)
          end

          it "should have the :correct state" do
            @sudoku[test_case[:row], test_case[:col]] = 8
            expect(@sudoku[test_case[:row], test_case[:col]][:state]).to eq(:correct)
          end
        end
      end

      it "should prevent changing starting digits" do
        @sudoku[0, 5] = 6
        expect(@sudoku[0, 5][:digit]).to eq(5)
      end
    end

    context "wrong digit placement" do
      context "same row" do
        it "should place the digit" do
          @sudoku[0, 3] = 5
          expect(@sudoku[0, 3][:digit]).to eq(5)
        end

        it "should have the :wrong state" do
          @sudoku[0, 3] = 5
          expect(@sudoku[0, 3][:state]).to eq(:wrong)
        end
      end

      context "same column" do
        it "should place the digit" do
          @sudoku[6, 2] = 4
          expect(@sudoku[6, 2][:digit]).to eq(4)
        end

        it "should have the :wrong state" do
          @sudoku[6, 2] = 4
          expect(@sudoku[6, 2][:state]).to eq(:wrong)
        end
      end

      context "same group" do
        it "should place the digit" do
          @sudoku[2, 0] = 3
          expect(@sudoku[2, 0][:digit]).to eq(3)
        end

        it "should have the :wrong state" do
          @sudoku[2, 0] = 3
          expect(@sudoku[2, 0][:state]).to eq(:wrong)
        end
      end
    end

    context "multiple placements" do
      before(:each) do
        @sudoku = Sudoku.new
        @sudoku.place_start_digit(0, 1, 3)
        @sudoku.place_start_digit(0, 5, 5)
        @sudoku.place_start_digit(1, 2, 4)
      end

      context "two cells are in conflict" do
        before(:each) do
          @sudoku[1, 4] = 3
          @sudoku[1, 1] = 3
        end

        it "sets both cells to the :wrong state" do
          expect(@sudoku[1, 4][:state]).to eq(:wrong)
          expect(@sudoku[1, 1][:state]).to eq(:wrong)
        end

        it "does not affect the starting digit in conflict" do
          expect(@sudoku[0, 1][:state]).to eq(:correct)
        end

        context "then one cell is corrected" do
          before(:each) do
            @sudoku[1, 1] = 8
          end

          it "sets both cells back to the :correct state" do
            expect(@sudoku[1, 4][:state]).to eq(:correct)
            expect(@sudoku[1, 1][:state]).to eq(:correct)
          end

          it "does not affect the starting digit in conflict" do
            expect(@sudoku[0, 1][:state]).to eq(:correct)
          end
        end
      end
    end

    context "placement makes multiple cells :wrong" do
      before(:each) do
        @sudoku = Sudoku.new
        @sudoku.place_start_digit(1, 4, 5)
        @sudoku[4, 7] = 5
        @sudoku[5, 3] = 5
      end

      it "should set each wrong digit to :wrong" do
        @sudoku[4, 4] = 5

        expect(@sudoku[4, 4][:state]).to eq(:wrong)
        expect(@sudoku[4, 7][:state]).to eq(:wrong)
        expect(@sudoku[5, 3][:state]).to eq(:wrong)
      end
    end
  end
end
