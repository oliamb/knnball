# encoding: UTF-8

# Copyright (C) 2011 Olivier Amblet <http://olivier.amblet.net>
#
# knnball is freely distributable under the terms of an MIT license.
# See LICENSE or http://www.opensource.org/licenses/mit-license.php.



require 'minitest/autorun'
require 'knnball'
require 'spec_helpers'

module KnnBall
  
  describe KDTree do
    
    include KnnBall::SpecHelpers
    
    describe "building the tree" do
      it "must be an empty tree without params" do
        KDTree.new.must_be_empty
      end
      
      it "wont be an empty tree with data" do
        KDTree.new(Ball.new({:id => 1, :point => [1]})).wont_be_empty
      end
    end
    
    describe "find the nearest ball" do
      before :each do
        root = Ball.new(
          {:id => 4, :point => [5]}, 1,
          Ball.new({:id => 2, :point => [2]}, 1, 
            Ball.new({:id => 1, :point => [1]}), Ball.new({:id => 3, :point => [3]})
          ),
          Ball.new({:id => 6, :point => [13]}, 1,
            Ball.new({:id => 5, :point => [8]}),
            Ball.new({:id => 7, :point => [21]}, 1, nil, Ball.new({:id => 8, :point => [34]}))
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
        @root = Ball.new({:id => 4, :point => [5, 7]}, 1,
          Ball.new({:id => 2, :point => [3, 4]}, 1, Ball.new({:id => 1, :point => [2, 2]}), Ball.new({:id => 3, :point => [4, 8]})),
          Ball.new({:id => 6, :point => [13, 4]}, 1, Ball.new({:id => 5, :point => [8, 1]}),
            Ball.new({:id => 7, :point => [21, 6]}, 1, Ball.new({:id => 8, :point => [34, 5]})))
        )
        @ball_tree =   KDTree.new(@root)
      end
      
      it "return the nearest parent" do
        @ball_tree.parent_ball([13.2, 4.5]).value[:id].must_equal(8)
      end
    end
    
    describe "find the best nearest ball" do
      points = [
        {:id => 1, :point => [2, 2]},
        {:id => 2, :point => [3, 4]},
        {:id => 3, :point => [4, 8]},
        {:id => 4, :point => [5, 7]},
        {:id => 5, :point => [8, 1]},
        {:id => 6, :point => [13, 4]},
        {:id => 7, :point => [21, 6]},
        {:id => 8, :point => [34, 5]},
      ]
      
      before do
        @root = Ball.new({:id => 4, :point => [5, 7]}, 1,
          Ball.new({:id => 2, :point => [3, 4]}, 1,
            Ball.new({:id => 1, :point => [2, 2]}), Ball.new({:id => 3, :point => [4, 8]})
          ),
          Ball.new({:id => 6, :point => [13, 4]}, 1, 
            Ball.new({:id => 5, :point => [8, 1]}),
            Ball.new({:id => 7, :point => [21, 6]}, 1, 
              nil, 
              Ball.new({:id => 8, :point => [34, 5]})
            )
          )
        )
        @tree =   KDTree.new(@root)
      end
      
      points.each do |p|
        it "Should retrieve point #{p} if the exact location is given" do
          assert_equal p, @tree.nearest(p[:point])
        end
        
        p_near = p[:point].map {|c| c-0.1}
        it "Should retrieve point #{p} if #{p_near} is given" do
          assert_equal p, @tree.nearest(p_near)
        end
        
        it "Should retrieve 2 nearest points in the correct order for point #{p}" do
          # Points might be different as long as distance are equals
          expected = brute_force(p, points, 2).map do |r| 
            Math.sqrt( (p[:point][0]-r[:point][0])**2 + (p[:point][1]-r[:point][1])**2 )
          end
          results = @tree.nearest(p[:point], :limit => 2).map do |r|
            Math.sqrt( (p[:point][0]-r[:point][0])**2 + (p[:point][1]-r[:point][1])**2 )
          end
          assert_equal expected, results
        end
        
        it "Should retrieve 5 nearest points in the correct order for point #{p}" do
          # Points might be different as long as distance are equals
          bf = brute_force(p, points, 5)
          expected = bf.map do |r| 
            Math.sqrt( (p[:point][0]-r[:point][0])**2 + (p[:point][1]-r[:point][1])**2 )
          end
          nn = @tree.nearest(p[:point], :limit => 5)
          results = nn.map do |r|
            Math.sqrt( (p[:point][0]-r[:point][0])**2 + (p[:point][1]-r[:point][1])**2 )
          end
          assert_equal expected, results, "bf: #{bf.inspect} -- nn: #{nn.inspect}"
        end
      end
    end
    
    describe "tree to array" do
      it "Should return an empty array if empty" do
        KDTree.new().to_a.must_equal []
      end
      
      it "Should return a tree array if not nil" do
        KDTree.new(Ball.new({:id => 1, :point => [1, 2, 3]})).to_a.must_equal [{:id => 1, :point => [1,2,3]}, nil, nil]
      end
    end
  end
end