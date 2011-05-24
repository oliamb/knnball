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
  class Ball
    attr_accessor :left, :right, :value, :dimension
    
    # @param value associated to this ball
    # @param actual_dimension the dimension used for sorting left and right tree
    def initialize(value, dimension = 1, left = nil, right = nil)
      unless (value.kind_of? Hash)
        raise ArgumentError.new("value must be a hash but is #{value.inspect}")
      end
      unless (value.include?(:id) && value.include?(:coord))
        raise ArgumentError.new("value must contains :id and :coord keys but is #{value.inspect}")
      end
      @value = value
      @right = right
      @dimension = dimension
      @left = left
    end
    
    def coord
      @value[:coord]
    end
    alias :center :coord
    
    def nearest(target, min)
      result = nil
      d = [distance(target), min[0]].min
      if d < min[0]
        min[0] = d
        result = self
      end
      
      # determine if we need to dive into sub tree
      dp = (coord[dimension-1] - target[dimension-1]).abs
      new_result = nil
      if(dp < min[0])
        # must dive into both left and right
        unless(left.nil?)
          new_result = left.nearest(target, min)
          result = new_result unless new_result.nil?
        end
        unless right.nil?
          new_result = right.nearest(target, min)
          result = new_result unless new_result.nil?
        end
      else
        # only need to dive in one
        if(target[dimension-1] < coord[dimension-1])
          unless(left.nil?)
            new_result = left.nearest(target, min)
          end
        else
          unless(right.nil?)
            new_result = right.nearest(target, min)
          end
        end
        result = new_result unless new_result.nil?
      end
      return result
    end
    
    # compute manhattan distance
    def distance(coordinates)
      Math.sqrt([coord, coordinates].transpose.map {|a,b| (b - a)**2}.reduce {|d1,d2| d1 + d2})
    end
    
    def radius
      l = (@left.nil? ? 0 : distance_from(@left) + @left.radius)
      r = (@right.nil? ? 0 : r_farest = distance_from(@right) + @right.radius)
      [l, r].max
    end
    
    # Retrieve true if this is a leaf ball.
    #
    # A leaf ball has no sub_balls.
    def leaf?
      @left.nil? && @right.nil?
    end
    
    def to_a
      [@value, @left.to_a, @right.to_a]
    end
    
    # return the nearest ball from this location
    def near(location)
      if(leaf?)
        return self, distance_from_location(location)
      end
      
      results = [[self, distance_from_location(location)]]
      
      [left, right].each do |branch|
        unless(branch.nil?)
          dist = branch.distance_from_location(location)
          results << branch.near(location)
        end
      end
      results.min {|line| line[1]}
    end
    
    def distance_from_location(location)
      Math.sqrt(([center, location].transpose.map {|a,b| (a-b) ** 2}.reduce(0) {|s, v| s = s + v}))
    end
    
    def distance_from(ball)
      return 0 if ball.nil?
      return distance_from_location(ball.center)
    end
    
    def to_s
      "<KnnBall::Ball @value=#{@value.inspect} @left=#{@left} @right=#{@right}>"
    end
    
    def id
      @value[:id]
    end
  end
end