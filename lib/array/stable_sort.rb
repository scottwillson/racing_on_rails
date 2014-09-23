class Array
  # Sort by +method+ and preserve existing order. Ruby 1.8 sort_by does not preserve order.
  def stable_sort_by(method, order = :asc)
    if order == :asc
      _stable_merge_sort { |x, y|
        if x.send(method).nil?
          true
        elsif !x.send(method).nil? && y.send(method).nil?
          false
        else
          x.send(method) >= y.send(method)
        end
      }
    elsif order == :desc
      _stable_merge_sort { |x, y|
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

  private

  # Sort is stable only if predicate includes an equal comparison. Example: x.name <= y.name
  def _stable_merge_sort(&predicate)
    return self.dup if size <= 1
    mid = size / 2
    left  = self[0, mid].dup
    right = self[mid, size].dup
    _stable_merge(left._stable_merge_sort(&predicate), right._stable_merge_sort(&predicate), &predicate)
  end

  def _stable_merge(left, right, &predicate)
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
