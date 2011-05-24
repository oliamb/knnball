# encoding: UTF-8

# Copyright (C) 2011 Olivier Amblet <http://olivier.amblet.net>
#
# SGSM Directory is freely distributable under the terms of an MIT license.
# See LICENSE or http://www.opensource.org/licenses/mit-license.php.



# This module is used as namespace for every elements of
# the knnball library.
module KnnBall
  
  autoload :Ball, 'knnball/ball'
  autoload :Stat, 'knnball/stat'
  autoload :KDTree, 'knnball/kdtree'
  
  # Retrieve a new BallTree given an array of input values.
  #
  # Each data entry in the array is a Hash containing
  # keys :value and :coord, an array of position (one per dimension)
  # [ {:value => 1, :coord => [1.23, 2.34, -1.23, -22.3]}, 
  # {:value => 2, :coord => [-2.33, 4.2, 1.23, 332.2]} ]
  #
  # @param data an array of Hash containing :value and :coord key
  #
  # @see KnnBall::KDTree#initialize
  def self.build(data)
    if(data.nil? || data.empty?)
      raise ArgumentError.new("data argument must be a not empty Array")
    end
    max_dimension = data.first[:coord].size
    kdtree = KDTree.new(max_dimension)
    kdtree.root = generate(data, max_dimension)
    return kdtree
  end
  
  # Generate the KD-Tree hyperrectangle.
  #
  # @param actual_dimension the dimension to base comparison on
  # @param max_dimension the number of dimension of each points
  # @param data the list of all points
  # @param left the first data index to look for
  # @param right the last data index to look for
  def self.generate(data, max_dimension, actual_dimension = 1)
    return nil if data.nil?
    return Ball.new(data.first) if data.size == 1
    
    # Order the array such as the middle point is the median and 
    # that every point on the left are of lesser value than median
    # and that every point on the right are of greater value
    # than the median. They are not more sorted than that.
    median_idx = Stat.median_index(data)
    value = Stat.median!(data) {|v1, v2| v1[:coord][actual_dimension-1] <=> v2[:coord][actual_dimension-1]}
    ball = Ball.new(value)
    
    actual_dimension = (max_dimension == actual_dimension ? 1 : actual_dimension)
    
    ball.left = generate(data[0..(median_idx-1)], max_dimension, actual_dimension) if median_idx > 0
    ball.right = generate(data[(median_idx+1)..-1], max_dimension, actual_dimension) if median_idx < (data.count)
    return ball
  end
  
  # Retrieve an internal string representation of the index
  # that can then be persisted.
  def self.marshall(ball_tree)
    return ""
  end
  
  # Retrieve a BallTree instance from a previously marshalled instance.
  def self.unmarshall(marshalled_content)
    return KDTree.new
  end
  
  # Retrieve the k nearest neighbor of the given position.
  def self.find_knn(ball_tree, position, k = 1, options = Hash.new)
    return []
  end
end