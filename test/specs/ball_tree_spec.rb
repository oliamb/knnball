require 'minitest/autorun'
require 'knnball'


module KnnBall
  
  describe BallTree do
    
    before :each do
      # Make private method public (white box testing)
      BallTree.send(:public, *BallTree.private_instance_methods)  
    end
    
    describe "building the tree" do
      it "must be an empty tree without params" do
        BallTree.new.must_be_empty
      end
      
      it "wont be an empty tree with data" do
        BallTree.new([{:id => 1, :location => [1]}]).wont_be_empty
      end
      
      it "must build a one dimension tree correctly" do
        BallTree.new(
          [{:id => 2, :location => [2]},
            {:id => 3, :location => [3]},
            {:id => 1, :location => [1]}]
        ).to_a.must_equal [{:id => 2, :location => [2]},
            [{:id => 3, :location => [3]}, [], []],
            [{:id => 1, :location => [1]}, [], []]
          ]
      end
    end
    
    describe "tree to array" do
      it "Should return an empty array if empty" do
        BallTree.new().to_a.must_equal []
      end
      
      it "Should return a tree array if not nil" do
        BallTree.new([{:id => 1, :location => [1, 2, 3]}]).to_a.must_equal [{:id => 1, :location => [1,2,3]}, [], []]
      end
    end
  end
end