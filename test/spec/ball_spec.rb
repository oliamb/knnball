# encoding: UTF-8

# Copyright (C) 2011 Olivier Amblet <http://olivier.amblet.net>
#
# knnball is freely distributable under the terms of an MIT license.
# See LICENSE or http://www.opensource.org/licenses/mit-license.php.

require 'minitest/autorun'
require 'knnball'

module KnnBall
  
  describe Ball do
          
    describe "Leaf balls" do
      before :each do
        @value = {:id => 1, :point => [1,2,3]}
        @ball = Ball.new(@value)
      end
      
      it "must be a leaf" do
        @ball.leaf?.must_equal true
      end
      
      it "must have a center equals to the value location" do
        @ball.center.must_equal @value[:point]
      end
      
      it "must convert itself to an Array instance" do
        @ball.to_a.must_equal [@value, nil, nil]
      end
      
      it "must convert itself to a Hash instance" do
        @ball.to_h.must_equal({:value => @value, :left => nil, :right => nil})
      end
    end
    
    describe "Standard Balls" do
      before :each do
        @value = {:id => 1, :point => [1,2,3]}
        @ball = Ball.new(@value, 1, Ball.new({:id => 3, :point => [-1, -2, -3]}), Ball.new({:id => 2, :point => [2, 3, 4]}))
      end
      
      it "wont be a leaf" do
        @ball.leaf?.must_equal false
      end
      
      it "must_be_centered_at_the_ball_value_location" do
        @ball.center.must_equal @value[:point]
      end
      
      it "must convert itself to an Array instance" do
        @ball.to_a.must_equal([
          @value, 
          [{:id => 3, :point => [-1, -2, -3]}, nil, nil],
          [{:id => 2, :point => [2, 3, 4]}, nil, nil]
        ])
      end
      
      it "must convert itself to a Hash instance" do
        @ball.to_h.must_equal({:value => @value, 
          :left => {:value => {:id => 3, :point => [-1, -2, -3]}, :left => nil, :right => nil}, 
          :right => {:value => {:id => 2, :point => [2, 3, 4]}, :left => nil, :right => nil}
        })
      end
    end
    
    describe "Ball with sub-balls" do
      before :each do
        @value = {:id => 1, :point => [1,2,3]}
        @leaf_1 = Ball.new(@value)
        @leaf_2 = Ball.new({:id => 2, :point => [2, 3, 4]})
        @leaf_3 = Ball.new({:id => 3, :point => [-1, -2 , -5]})
        @leaf_4 = Ball.new({:id => 4, :point => [-3, -2, -2]})
        @sub_ball_1 = Ball.new({:id => 5, :point => [1.4, 2, 2.5]}, 1, @leaf_1, @leaf_2)
        @sub_ball_2 = Ball.new({:id => 6, :point => [-2, -1.9, -3]}, 1, @leaf_3, @leaf_4)
        @ball = Ball.new({:id => 7, :point => [0, 0, 0]}, 1, @sub_ball_1, @sub_ball_2)
      end
      
      it "must be centered at (0,0,0)" do
        @ball.center.must_equal([0,0,0])
      end
    end
    
    describe "distance from private method" do
      before :each do
        # Make private method public (white box testing)
        Ball.send(:public, *Ball.private_instance_methods)  
      end
      
      it "retrieve the correct distance" do
        b1 = Ball.new({:id => 2, :point => [2, 3, 4]})
        b2 = Ball.new({:id => 3, :point => [-1, -2 , -5]})
        b1.distance(b2).must_equal(Math.sqrt(115))
      end
    end
  end
end