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

    # @param value the value associated to this ball
    # @param actual_dimension the dimension used for sorting left and right tree
    def initialize(value, dimension = 1, left = nil, right = nil)
      unless (value.respond_to?(:include?) && value.respond_to?(:[]))
        raise ArgumentError.new("Value must at least respond to methods include? and [].")
      end
      unless (value.include?(:point))
        raise ArgumentError.new("value must contains :point key but has only #{value.keys.inspect}")
      end
      @value = value
      @right = right
      @dimension = dimension
      @left = left
    end

    def center
      value[:point]
    end

    def nearest(target, min)
      result = nil
      d = [quick_distance(target), min[0]].min
      if d < min[0]
        min[0] = d
        result = self
      end

      # determine if we need to dive into sub tree
      dp = (center[dimension-1] - target[dimension-1]).abs
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
        if(target[dimension-1] < center[dimension-1])
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

    # Compute euclidien distance.
    #
    # @param coordinates an array of coord or a Ball instance
    def distance(coordinates)
      coordinates = coordinates.center if coordinates.respond_to?(:center)
      Math.sqrt([center, coordinates].transpose.map {|a,b| (b - a)**2}.reduce {|d1,d2| d1 + d2})
    end

    # Quickly compute a distance using Manhattan
    def quick_distance(coordinates)
      distance(coordinates)
#      coordinates = coordinates.center if coordinates.respond_to?(:center)
#      [center, coordinates].transpose.map {|a,b| (b - a)**2}.reduce {|d1,d2| d1 + d2}
#      [center, coordinates].transpose.map {|a,b| (b - a).abs}.reduce {|d1,d2| d1 + d2}
    end

    def count
      1 + (left.nil? ? 0 : left.count) + (right.nil? ? 0 : right.count)
    end

    # Retrieve true if this is a leaf ball.
    #
    # A leaf ball has no sub_balls.
    def leaf?
      @left.nil? && @right.nil?
    end

    # Return true if this ball has a left and a right ball
    def complete?
      ! (@left.nil? || @right.nil?)
    end

    # Generate an Array from this Ball.
    #
    # index 0 contains the value object,
    # index 1 contains the left ball or nil,
    # index 2 contains the right ball or nil.
    def to_a
      if leaf?
        [@value, nil, nil]
      else
        [@value, (@left.nil? ? nil : @left.to_a), (@right.nil? ? nil : @right.to_a)]
      end
    end

    # Generate a Hash from this Ball instance.
    #
    # The generated instance contains keys :id, :left and :right
    def to_h
      if leaf?
        {:value => @value, :left => nil, :right => nil}
      else
        {:value => @value, :left => (@left.nil? ? nil : @left.to_h), :right => (@right.nil? ? nil : @right.to_h)}
      end
    end
  end
end