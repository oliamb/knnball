# encoding: UTF-8

# Copyright (C) 2011 Olivier Amblet <http://olivier.amblet.net>
#
# SGSM Directory is freely distributable under the terms of an MIT license.
# See LICENSE or http://www.opensource.org/licenses/mit-license.php.



module KnnBall
  # This class represents a ball in the tree.
  #
  # The value of this ball will be its center
  # while its radius is the distance between the center and
  # the most far sub-ball.
  class Ball
    attr_accessor :left, :right
    
    # @param value a Hash containing :id and :location keys
    # @param left_ball the left ball
    # @param right_ball the right ball
    def initialize(value, left_branch = nil, right_branch = nil)
      unless (value.kind_of? Hash)
        raise ArgumentError.new("value must be a hash but is #{value.inspect}")
      end
      unless (value.include?(:id) && value.include?(:location))
        raise ArgumentError.new("value must contains :id and :location keys but is #{value.inspect}")
      end
      @left = left_branch
      @right = right_branch
      @value = value
    end
    
    def center
      @value[:location]
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
          dst = branch.distance_from_location(location)
          if(dst <= branch.radius)
            results << branch.near(location)
          end
        end
      end
      
      results.min {|ball, dst| dst}
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
  end
end