require_relative '../helper.rb'
require 'minitest/autorun'
require 'knnball'


module KnnBall
  
  describe BallTree do
    
    before :each do
      @value = {:id => 1, :location => [1,2,3]}
    end
          
    describe "Leaf balls" do
      it "must be a leaf" do
        Ball.new(@value).leaf?.must_equal true
      end
      
      it "must have a radius of 0" do
        Ball.new(@value).radius.must_equal 0
      end
      
      it "must have a center equals to the value location" do
        Ball.new(@value).center.must_equal @value[:location]
      end
    end
    
    describe "Standard Balls" do
      before :each do
        @ball = Ball.new(@value, Ball.new({:id => 2, :location => [2, 3, 4]}), Ball.new({:id => 3, :location => [-1, -2, -3]}))
      end
      
      it "wont be a leaf" do
        @ball.leaf?.must_equal false
      end
      
      it "must_have_a_correct_radius" do
        @ball.radius.must_equal Math.sqrt(56)
        @ball.center.must_equal @value[:location]
      end
      
      it "must_be_centered_at_the_ball_value_location" do
        @ball.center.must_equal @value[:location]
      end
      
      it "must_have_positive_radius_with_negative_location" do
        b = Ball.new({:id => 1, :location => [-5, -5, -5]}, Ball.new({:id => 2, :location => [-2, -3, -4]}), Ball.new({:id => 3, :location => [-1, -2, -3]}))
        b.radius.must_equal Math.sqrt(29)
      end
    end
    
    describe "Ball with sub-balls" do
      before :each do
        @leaf_1 = Ball.new(@value)
        @leaf_2 = Ball.new({:id => 2, :location => [2, 3, 4]})
        @leaf_3 = Ball.new({:id => 3, :location => [-1, -2 , -5]})
        @leaf_4 = Ball.new({:id => 4, :location => [-3, -2, -2]})
        @sub_ball_1 = Ball.new({:id => 5, :location => [1.4, 2, 2.5]}, @leaf_1, @leaf_2)
        @sub_ball_2 = Ball.new({:id => 6, :location => [-2, -1.9, -3]}, @leaf_3, @leaf_4)
        @ball = Ball.new({:id => 7, :location => [0, 0, 0]}, @sub_ball_1, @sub_ball_2)
      end
      
      it "must be centered at (0,0,0)" do
        @ball.center.must_equal([0,0,0])
      end
      
      it "must have a radius equals to the distance between the center and the farest ball center plus radius" do
        @ball.radius.must_equal 6.313839703022905, @ball.radius ** 2
      end
    end
    
    describe "distance from private method" do
      before :each do
        # Make private method public (white box testing)
        Ball.send(:public, *Ball.private_instance_methods)  
      end
      
      it "retrieve the correct distance" do
        b1 = Ball.new({:id => 2, :location => [2, 3, 4]})
        b2 = Ball.new({:id => 3, :location => [-1, -2 , -5]})
        b1.distance_from(b2).must_equal(Math.sqrt(115))
      end
    end
  end
end