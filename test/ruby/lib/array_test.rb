require File.expand_path("../../test_case", __FILE__)
require File.expand_path("../../../../lib/array/each_with_index", __FILE__)
require File.expand_path("../../../../lib/array/stable_sort", __FILE__)

# :stopdoc:
class ArrayTest < Ruby::TestCase
  def test_each_row_with_index
    assert_equal([[], 0], [].each_row_with_index {|row, index|}, 'rows with index')
    assert_equal([[[1]], 0], [1].each_row_with_index {|row, index|}, 'rows with index')
    assert_equal([[[1, 2]], 0], [1, 2].each_row_with_index {|row, index|}, 'rows with index')
    assert_equal([[[1, 3], [2]], 1], [1, 2, 3].each_row_with_index {|row, index|}, 'rows with index')
    assert_equal([[[1, 3], [2, 4]], 1], [1, 2, 3, 4].each_row_with_index {|row, index|}, 'rows with index')
    assert_equal([[[1, 4], [2, 5], [3, 6]], 2], [1, 2, 3, 4, 5, 6].each_row_with_index {|row, index|}, 'rows with index')
  end
  
  def test_merge_sort
    assert_equal([], [].merge_sort, "[].merge_sort")
    assert_equal([9], [9].merge_sort, "[9].merge_sort")
    assert_equal([1, 2], [1, 2].merge_sort, "[1, 2].merge_sort")
    assert_equal([1, 2, 7], [7, 1, 2].merge_sort, "[7, 1, 2].merge_sort")
    assert_equal([-20, 0, 0, 0, 1, 2, 7], [0, 0, 7, 1, 2, 0, -20].merge_sort, "[0, 0, 7, 1, 2, 0, -20].merge_sort")

    assert_equal_enumerables([-20, 0, 0, 0, 1, 2, 7], 
                             [0, 0, 7, 1, 2, 0, -20].merge_sort { |x, y| x > y }, 
                            "[0, 0, 7, 1, 2, 0, -20].merge_sort { |x, y| x > y }")

    assert_equal_enumerables([7, 2, 1, 0, 0, 0, -20], 
                             [0, 0, 7, 1, 2, 0, -20].merge_sort { |x, y| x < y }, 
                            "[0, 0, 7, 1, 2, 0, -20].merge_sort { |x, y| x < y }")
  end
  
  def test_merge_sort_preserves_order
    king_hearts   = Card.new("king", "hearts")
    king_diamonds = Card.new("king", "diamonds")
    king_spades   = Card.new("king", "spades")
    king_clubs    = Card.new("king", "clubs")

    assert_equal_enumerables(
                [king_hearts, king_diamonds, king_spades, king_clubs], 
                [king_hearts, king_diamonds, king_spades, king_clubs].merge_sort,
                "merge_sort of equal elements should preserve order")

    assert_equal_enumerables(
                [king_hearts, king_diamonds, king_spades, king_clubs], 
                [king_hearts, king_diamonds, king_spades, king_clubs].merge_sort { |x, y| x.value > y.value },
                "merge_sort of equal elements should preserve order")

    assert_equal_enumerables(
                [king_hearts, king_diamonds, king_spades, king_clubs], 
                [king_hearts, king_diamonds, king_spades, king_clubs].merge_sort { |x, y| x.value < y.value },
                "merge_sort of equal elements should preserve order")

    assert_equal_enumerables(
                [king_clubs, king_diamonds, king_hearts, king_spades], 
                [king_hearts, king_diamonds, king_spades, king_clubs].merge_sort { |x, y| x.suit > y.suit },
                "merge_sort of equal elements should preserve order")

    assert_equal_enumerables(
                [king_spades, king_hearts, king_diamonds, king_clubs], 
                [king_hearts, king_diamonds, king_spades, king_clubs].merge_sort { |x, y| x.suit < y.suit },
                "merge_sort of equal elements should preserve order")
  end
  
  def test_multiple_sorts_preserve_order
    king_hearts   = Card.new(14, "hearts")
    diamonds_10   = Card.new(10, "diamonds")
    diamonds_8    = Card.new( 8, "diamonds")
    hearts_queen  = Card.new(13, "hearts")
    
    list = [king_hearts, diamonds_10, diamonds_8, hearts_queen]
    list = list.merge_sort { |x, y| x.suit >= y.suit }
    assert_equal_enumerables([diamonds_10, diamonds_8, king_hearts, hearts_queen], list, "Sorted by suit")
    
    list = list.merge_sort { |x, y| x.value >= y.value }
    assert_equal_enumerables([diamonds_8, diamonds_10, hearts_queen, king_hearts], list, "Sorted by value")

    list = list.merge_sort { |x, y| x.suit >= y.suit }
    list = list.merge_sort { |x, y| x.value >= y.value }
    list = list.merge_sort { |x, y| x.suit >= y.suit }
    list = list.merge_sort { |x, y| x.value >= y.value }
    list = list.merge_sort { |x, y| x.suit >= y.suit }
    list = list.merge_sort { |x, y| x.value >= y.value }
    list = list.merge_sort { |x, y| x.suit >= y.suit }
    list = list.merge_sort { |x, y| x.value >= y.value }
    assert_equal_enumerables([diamonds_8, diamonds_10, hearts_queen, king_hearts], list, "Sorted by value")
  end
  
  def test_stable_sort_by
    king_hearts   = Card.new(14, "hearts")
    diamonds_10   = Card.new(10, "diamonds")
    diamonds_8    = Card.new( 8, "diamonds")
    hearts_queen  = Card.new(13, "hearts")
    
    list = [king_hearts, diamonds_10, diamonds_8, hearts_queen]
    list = list.stable_sort_by(:suit)
    assert_equal_enumerables([diamonds_10, diamonds_8, king_hearts, hearts_queen], list, "Sorted by suit")

    list = list.stable_sort_by(:value)
    assert_equal_enumerables([diamonds_8, diamonds_10, hearts_queen, king_hearts], list, "Sorted by value")

    list = list.stable_sort_by(:suit)
    list = list.stable_sort_by(:value)
    list = list.stable_sort_by(:suit)
    list = list.stable_sort_by(:value)
    list = list.stable_sort_by(:suit)
    list = list.stable_sort_by(:value)
    list = list.stable_sort_by(:suit)
    list = list.stable_sort_by(:value)
    assert_equal_enumerables([diamonds_8, diamonds_10, hearts_queen, king_hearts], list, "Sorted by value")

    list = list.stable_sort_by(:value, :desc)
    assert_equal_enumerables([king_hearts, hearts_queen, diamonds_10, diamonds_8], list, "Sorted by value desc")
  end
  
  def test_stable_sort_nil
    diamonds_10   = Card.new(10, "diamonds")
    diamonds_nil  = Card.new(nil, "diamonds")
    hearts_queen  = Card.new(13, "hearts")

    list = [diamonds_10, diamonds_nil, hearts_queen]
    list = list.stable_sort_by(:value)
    assert_equal_enumerables([diamonds_10, hearts_queen, diamonds_nil], list, "Sorted by value")
  end
end

class Card
  attr_accessor :value
  attr_accessor :suit
  
  include Comparable
  
  def initialize(value, suit)
    @value = value
    @suit = suit
  end
  
  def <=>(value)
    return -1 unless value
    self.value <=> value.value
  end
  
  def to_s
    "#{value} #{suit}"
  end
end