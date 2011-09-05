# encoding: UTF-8

# Copyright (C) 2011 Olivier Amblet <http://olivier.amblet.net>
#
# knnball is freely distributable under the terms of an MIT license.
# See LICENSE or http://www.opensource.org/licenses/mit-license.php.

module KnnBall
  # This class represents a ball in the tree.
  #
  # The value of this ball will be its center
  # while its radius is the distance between the center and
  # the most far sub-ball.
  class ResultSet
    attr_reader :limit, :barrier_value
    
    def initialize(options = {})
      @limit = options[:limit] || 10
      @items = []
      @barrier_value = options[:barrier_value]
    end
    
    def eligible?(value)
      @barrier_value.nil? || @items.count < limit || value < @barrier_value
    end
    
    def add(value, item)
      return false unless(eligible?(value))
      
      if @items.count == limit
        @items.pop
      end
      
      if @barrier_value.nil? || value > @barrier_value || @items.empty?
        @barrier_value = value
        @items.push [value, item]
      else
        idx = 0
        while(value > @items[idx][0])
          idx = idx + 1
        end
        @items.insert idx, [value, item]
      end
      
      @barrier_value = @items.last[0]
      return true
    end
    
    def items
      @items.map {|i| i[1]}
    end
  end
end
