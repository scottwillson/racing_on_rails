# frozen_string_literal: true

module Enumerable
  # Sort by +method+ and preserve existing order. Ruby sort_by does not preserve order.
  def stable_sort_by(method, order = :asc)
    case order
    when :asc
      merge_sort do |x, y|
        if x.send(method).nil?
          true
        elsif !x.send(method).nil? && y.send(method).nil?
          false
        else
          x.send(method) >= y.send(method)
        end
      end
    when :desc
      merge_sort do |x, y|
        if y.send(method).nil?
          true
        elsif !y.send(method).nil? && x.send(method).nil?
          false
        else
          x.send(method) <= y.send(method)
        end
      end
    else
      raise ArgumentError, "order must be :asc or :desc"
    end
  end

  # Sort is stable only if predicate includes an equal comparison. Example: x.name <=> y.name
  def merge_sort(&predicate)
    return dup if size <= 1

    mid = size / 2
    left  = self[0, mid].dup
    right = self[mid, size].dup
    _stable_merge(left.merge_sort(&predicate), right.merge_sort(&predicate), &predicate)
  end

  private

  def _stable_merge(left, right, &predicate)
    sorted = []
    until left.empty? || right.empty?
      sorted << if predicate
                  if yield(right.first, left.first)
                    left.shift
                  else
                    right.shift
                  end
                elsif left.first <= right.first
                  left.shift
                else
                  right.shift
                end
    end
    sorted.concat(left).concat(right)
  end
end
