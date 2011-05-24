require 'minitest/autorun'
require 'knnball'
require 'json'

describe KnnBall do
  before do
    @ball_tree = MiniTest::Mock.new
  end
  
  describe "when asked to build the tree" do
    it "must retrieve a KDTree instance" do
      KnnBall.build([
        {:id => 1, :coord => [1.0,1.0]},
        {:id => 2, :coord => [2.0, 3.0]}
      ]).must_be :kind_of?, KnnBall::KDTree
    end
    
    it "must build a one dimension tree correctly" do
      tree = KnnBall.build(
        [{:id => 2, :coord => [2]},
          {:id => 3, :coord => [3]},
          {:id => 1, :coord => [1]}]
      )
      tree.root.value.must_equal({:id => 2, :coord => [2]})
      tree.root.left.value.must_equal({:id => 1, :coord => [1]})
      tree.root.left.left.must_be_nil
      tree.root.left.right.must_be_nil
      tree.root.right.wont_be_nil
      tree.root.right.value.must_equal({:id => 3, :coord => [3]})
      
      KnnBall.build([
          {:id => 1, :coord => [1]},
          {:id => 2, :coord => [2]},
          {:id => 3, :coord => [3]},
          {:id => 4, :coord => [5]},
          {:id => 5, :coord => [8]},
          {:id => 6, :coord => [13]},
          {:id => 7, :coord => [21]},
          {:id => 8, :coord => [34]}
        ]).root.value.must_equal({:id => 4, :coord => [5]})
    end
  end
  
  describe "when asked to serialize the index" do
    it "must retrieve a string" do
      KnnBall.marshall(@ball_tree).must_be :kind_of?, String
    end
  end
  
  describe "when asked to load an index" do
    it "must retrieve a a BallTree instance" do
      KnnBall.unmarshall("").must_be :kind_of?, KnnBall::KDTree
    end
  end
  
  describe "when asked to find the neareast location" do
    it "retrieve the nearest location" do
      result = KnnBall.find_knn(@ball_tree, [1, 1, 1, 1])
      result.must_be :kind_of?, Array
    end
    
    it "retrieve the same results as a brute force approach" do
      json = File.open(File.join(File.dirname(__FILE__), 'data.json'), 'r:utf-8').read
      data = JSON.parse(json)
      data = data.map do |l|
        h = {}
        l.each {|k,v| h[k.to_sym] = v}
        h
      end
      
      tree = KnnBall.build(data)
      errors = []
      msgs = []
      data.each do |p|
        t0 = Time.now
        res = data.map do |p2|
          euc = Math.sqrt((p2[:coord][0] - p[:coord][0])**2.0 + (p2[:coord][1] - p[:coord][1])**2.0)
          [p2, euc]
        end
        best = res.min {|a, b| a.last <=> b.last}
        brute_force_result = best.first
        t1 = Time.now
        p[:coord].must_equal(brute_force_result[:coord])
        t2 = Time.now
        nn_result = tree.nearest(p[:coord])
        t3 = Time.now
        if(nn_result[:coord] != brute_force_result[:coord])
          errors << [p, nn_result, brute_force_result]
        end
        if(t1-t0 < t3-t2)
          msgs << "For #{p}, efficiency was before with bruteforce than with kdtree search."
        end
      end
      
      msgs = errors.map do |e| 
        if(e[0] == e[1])
          "For #{e[0]}, OK, but brute force retrieved #{e[2]}"
        elsif(e[0] == e[2])
          "For #{e[0]}, #{e[1]} retrieved instead of #{e[2]}"
        else
          "For #{e[0]}, both brute force and nn search are wrong"
        end
      end
      must_be_empty errors
    end
  end
end