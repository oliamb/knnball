# encoding: UTF-8

# Copyright (C) 2011 Olivier Amblet <http://olivier.amblet.net>
#
# SGSM Directory is freely distributable under the terms of an MIT license.
# See LICENSE or http://www.opensource.org/licenses/mit-license.php.



# This module is used as namespace for every elements of
# the knnball library.
module KnnBall
  
  autoload :BallTree, 'knnball/ball_tree'
  autoload :Ball, 'knnball/ball' 
  
  # Retrieve a new BallTree given an array of input values.
  #
  # Each value in the array is a Hash containing
  # the :id index and :location, an array of position (one per dimension)
  # [ {:id => 1, :loc => [1.23, 2.34, -1.23, -22.3]}, 
  # {:id => 2, :loc => [-2.33, 4.2, 1.23, 332.2]} ]
  #
  # @see KnnBall::BallTree#initialize
  def self.build_tree(values)
    return BallTree.new
  end
  
  # Retrieve an internal string representation of the index
  # that can then be persisted.
  def self.marshall(ball_tree)
    return ""
  end
  
  # Retrieve a BallTree instance from a previously marshalled instance.
  def self.unmarshall(marshalled_content)
    return BallTree.new
  end
  
  # Retrieve the k nearest neighbor of the given position.
  def self.find_knn(ball_tree, position, k = 1, options = Hash.new)
    return []
  end
end