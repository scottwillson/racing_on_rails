class Array
  require 'enumerator'
  
  def each_row_with_index
    return [[], 0] if empty?
    rows = []
    row_count = (size + 1) / 2
    
    for row_index in 0..(row_count - 1)
      row = [self[row_index]]
      second_element_index = (row_count - 1) + row_index + 1
      if second_element_index < size
        row << self[second_element_index]
      end
      rows << row
      yield row, row_index
    end
    
    [rows, row_index]
  end
  
  def stable_sort_by(method, order = :asc)
    if order == :asc
      merge_sort { |x, y|
        if x.send(method).nil?
          true
        elsif !x.send(method).nil? && y.send(method).nil?
          false
        else
          x.send(method) >= y.send(method)
        end
      }
    elsif order == :desc
      merge_sort { |x, y|
        if y.send(method).nil?
          true
        elsif !y.send(method).nil? && x.send(method).nil?
          false
        else
          x.send(method) <= y.send(method)
        end
      }
    else
      raise ArgumentError, "order must be :asc or :desc"
    end
  end

  # Sort is stable only if predicate includes an equal comparison. Example: x.name <= y.name
  def merge_sort(&predicate)
    return self.dup if size <= 1
    mid = size / 2
    left  = self[0, mid].dup
    right = self[mid, size].dup
    merge(left.merge_sort(&predicate), right.merge_sort(&predicate), &predicate)
  end

  def merge(left, right, &predicate)
    sorted = []
    until left.empty? or right.empty?
      if predicate
        if predicate.call(right.first, left.first)
          sorted << left.shift
        else
          sorted << right.shift
        end
      else
        if left.first <= right.first
          sorted << left.shift
        else
          sorted << right.shift
        end
      end
    end
    sorted.concat(left).concat(right)
  end
 
end