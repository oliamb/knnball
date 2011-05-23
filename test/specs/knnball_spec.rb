require_relative '../helper.rb'
require 'minitest/autorun'
require 'knnball'

describe KnnBall do
  before do
    @ball_tree = MiniTest::Mock.new
  end
  
  describe "when asked to build the tree" do
    it "must retrieve a BallTree instance" do
      KnnBall.build_tree([
        {:id => 1, :pos => [1.0,1.0]},
        {:id => 2, :pos => [2.0, 3.0]}
      ]).must_be :kind_of?, KnnBall::BallTree
    end
  end
  
  describe "when asked to serialize the index" do
    it "must retrieve a string" do
      KnnBall.marshall(@ball_tree).must_be :kind_of?, String
    end
  end
  
  describe "when asked to load an index" do
    it "must retrieve a a BallTree instance" do
      KnnBall.unmarshall("").must_be :kind_of?, KnnBall::BallTree
    end
  end
  
  describe "when asked to find the neareast location" do
    it "retrieve the nearest location" do
      result = KnnBall.find_knn(@ball_tree, [1, 1, 1, 1])
      result.must_be :kind_of?, Array
    end
  end
end