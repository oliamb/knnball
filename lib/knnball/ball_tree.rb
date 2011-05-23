# encoding: UTF-8

# Copyright (C) 2011 Olivier Amblet <http://olivier.amblet.net>
#
# SGSM Directory is freely distributable under the terms of an MIT license.
# See LICENSE or http://www.opensource.org/licenses/mit-license.php.



module KnnBall
  # This class represents a whole ball tree.
  #
  # All values inside a BallTree are only using built-in objects
  # to ensure maximum speed.
  class BallTree
    
    # Retrieve an empty BallTree
    #
    # data is an Array whoose value is a Hash containing
    # the :id unique identifier and :location, an array of position (one per dimension)
    # [ {:id => 1, :loc => [1.23, 2.34, -1.23, -22.3]}, 
    # {:id => 2, :loc => [-2.33, 4.2, 1.23, 332.2]} ]
    #
    # @param data an array of Hash containing :id and :location key
    def initialize(data = nil)
      @tree = nil
      unless data.nil?
        insert_data(data)
      end
    end
    
    # Insert a value Hash into the tree
    #
    # @param value a Hash containing :id and :location keys.
    def insert(value)
      if(tree.nil?)
        @tree = Ball.new(value)
        return
      end
      
      # Find the ball with the nearest center
      nearest = nearest_ball(value[:location])
      ball = Ball.new(value)
      if nearest.leaf?
        # Add the new ball as a left leaf
        nearest.left = ball
      else
        # Decide wheter it should be inserted left, right or in place of the current leaf.
        ldst = ball.distance_from(nearest.left)
        rdst = ball.distance_from(nearest.right)
        if ldst < rdst
          #getting to left
          ball.left = nearest.left
          nearest.left = ball
          # missing: equilibrate and right
        else
          ball.right = nearest.right
          nearest.right = ball
          # missing: equilibrate and right
        end
      end
    end
    
    def empty?
      return tree.nil?
    end
    
    # return the tree as an array.
    # 
    # Array index 0 is the node value,
    # index 1 is the array of left sub nodes and 
    # index 2 is the array of right sub nodes.
    # This process repeat recursively.
    def to_a
      return tree.to_a
    end
    
  private
  
    def insert_data(data)
      if(data.nil?)
        raise ArgumentError.new("data should not be nil.")
      end
      data.each {|d| insert(d)}
    end
    
    def nearest_ball(location)
      ball, distance = tree.near(location)
      return ball
    end
    
    def tree
      @tree
    end
  end
end