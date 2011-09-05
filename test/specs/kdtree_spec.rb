# encoding: UTF-8

# Copyright (C) 2011 Olivier Amblet <http://olivier.amblet.net>
#
# knnball is freely distributable under the terms of an MIT license.
# See LICENSE or http://www.opensource.org/licenses/mit-license.php.



require 'minitest/autorun'
require 'knnball'


module KnnBall
  
  describe KDTree do
    
    describe "building the tree" do
      it "must be an empty tree without params" do
        KDTree.new.must_be_empty
      end
      
      it "wont be an empty tree with data" do
        KDTree.new(Ball.new({:id => 1, :coord => [1]})).wont_be_empty
      end
    end
    
    describe "find the nearest ball" do
      before :each do
        root = Ball.new(
          {:id => 4, :coord => [5]}, 1,
          Ball.new({:id => 2, :coord => [2]}, 1, 
            Ball.new({:id => 1, :coord => [1]}), Ball.new({:id => 3, :coord => [3]})
          ),
          Ball.new({:id => 6, :coord => [13]}, 1,
            Ball.new({:id => 5, :coord => [8]}),
            Ball.new({:id => 7, :coord => [21]}, 1, nil, Ball.new({:id => 8, :coord => [34]}))
          )
        )
        @ball_tree =   KDTree.new(root)
      end
      
      it "return a matching location" do
        @ball_tree.nearest([3])[:id].must_equal(3)
        @ball_tree.nearest([35])[:id].must_equal(8)
        @ball_tree.nearest([5])[:id].must_equal(4)
        @ball_tree.nearest([2])[:id].must_equal(2)
      end
    end
    
    describe "find the parent for coordinates" do
      before :each do
        @root = Ball.new({:id => 4, :coord => [5, 7]}, 1,
          Ball.new({:id => 2, :coord => [3, 4]}, 1, Ball.new({:id => 1, :coord => [2, 2]}), Ball.new({:id => 3, :coord => [4, 8]})),
          Ball.new({:id => 6, :coord => [13, 4]}, 1, Ball.new({:id => 5, :coord => [8, 1]}),
            Ball.new({:id => 7, :coord => [21, 6]}, 1, Ball.new({:id => 8, :coord => [34, 5]})))
        )
        @ball_tree =   KDTree.new(@root)
      end
      
      it "return the nearest parent" do
        @ball_tree.parent_ball([13.2, 4.5]).value[:id].must_equal(8)
      end
    end
    
    describe "tree to array" do
      it "Should return an empty array if empty" do
        KDTree.new().to_a.must_equal []
      end
      
      it "Should return a tree array if not nil" do
        KDTree.new(Ball.new({:id => 1, :coord => [1, 2, 3]})).to_a.must_equal [{:id => 1, :coord => [1,2,3]}, nil, nil]
      end
    end
  end
end