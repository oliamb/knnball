# encoding: UTF-8

# Copyright (C) 2011 Olivier Amblet <http://olivier.amblet.net>
#
# knnball is freely distributable under the terms of an MIT license.
# See LICENSE or http://www.opensource.org/licenses/mit-license.php.



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
        {:id => 1, :point => [1.0,1.0]},
        {:id => 2, :point => [2.0, 3.0]}
      ]).must_be :kind_of?, KnnBall::KDTree
    end
    
    it "must build a one dimension tree correctly" do
      tree = KnnBall.build(
        [{:id => 2, :point => [2]},
          {:id => 3, :point => [3]},
          {:id => 1, :point => [1]}]
      )
      tree.root.value.must_equal({:id => 2, :point => [2]})
      tree.root.left.value.must_equal({:id => 1, :point => [1]})
      tree.root.left.left.must_be_nil
      tree.root.left.right.must_be_nil
      tree.root.right.wont_be_nil
      tree.root.right.value.must_equal({:id => 3, :point => [3]})
      
      KnnBall.build([
          {:id => 1, :point => [1]},
          {:id => 2, :point => [2]},
          {:id => 3, :point => [3]},
          {:id => 4, :point => [5]},
          {:id => 5, :point => [8]},
          {:id => 6, :point => [13]},
          {:id => 7, :point => [21]},
          {:id => 8, :point => [34]}
        ]).root.value.must_equal({:id => 4, :point => [5]})
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
    before :each do
      json = File.open(File.join(File.dirname(__FILE__), 'data.json'), 'r:utf-8').read
      @data = JSON.parse(json)
      @data = @data.map do |l|
        h = {}
        l.each {|k,v| h[k.to_sym] = v}
        h
      end
    end
    
    it "retrieve the nearest location" do
      result = KnnBall.find_knn(@ball_tree, [1, 1, 1, 1])
      result.must_be :kind_of?, Array
    end
    
    def brute_force(point, data)
      res = @data.map do |p2|
        euc = Math.sqrt((p2[:point][0] - point[:point][0])**2.0 + (p2[:point][1] - point[:point][1])**2.0)
        [p2, euc]
      end
      best = res.min {|a, b| a.last <=> b.last}
      return best.first
    end
    
    it "retrieve the same results as a brute force approach" do
      tree = KnnBall.build(@data)
      msgs = []
      @data.each do |p|
        brute_force_result = brute_force(p, @data)
        p[:point].must_equal(brute_force_result[:point])
        nn_result = tree.nearest(p[:point])
        if(nn_result[:point] != brute_force_result[:point])
          msgs << "For #{p}, #{nn_result} retrieved amongs those 2 first results #{tree.nearest(p[:point], :limit => 2)}"
        end
      end
      must_be_empty msgs
    end
    
    it "is more efficient than the brute force approach" do
      tree = KnnBall.build(@data)
      msgs = []
      
      tree.nearest(@data.first[:point])
      
      @data.each do |p|
        t0 = Time.now
        brute_force_result = brute_force(p, @data)
        t1 = Time.now
        
        t2 = Time.now
        nn_result = tree.nearest(p[:point])
        t3 = Time.now
        
        dt_bf = t1-t0
        dt_kdtree = t3-t2
        
        if(dt_bf < dt_kdtree)
          msgs << "For #{p}, efficiency is better with brute force than with kdtree search. #{((dt_bf - dt_kdtree)/dt_bf * 100).to_i}%"
        end
      end
      assert( (msgs.count / @data.count) * 100 < 5, msgs.inspect )
    end
  end
  
  describe "When asked to retrieve the k nearest neighbors" do
    before :each do
      json = File.open(File.join(File.dirname(__FILE__), 'data.json'), 'r:utf-8').read
      @data = JSON.parse(json)
      @data = @data.map do |l|
        h = {}
        l.each {|k,v| h[k.to_sym] = v}
        h
      end
      
      assert @data.count > 10
      
      @index = KnnBall.build(@data)
      assert @index.count > 10
    end
    
    it "retrieve an array of results" do
      result = @index.nearest([46.23, 5.46], :limit => 10)
      result.kind_of?(Array).must_equal true
    end
    
    it "should contains 10 results" do
      result = @index.nearest([46.23, 5.46], :limit => 10)
      result.size.must_equal 10
    end
    
    it "should contains results from the nearer to the farest" do
      target = [46.18612, 6.118075]
      results = @index.nearest(target, :limit => 10)
      results.reduce do |r0, r1|
        p0, p1 = r0[:point], r1[:point]
        
        d0, d1 = Math.sqrt((p0[0] - target[0]) ** 2 + (p0[1] - target[1]) ** 2), Math.sqrt((p1[0] - target[0]) ** 2 + (p1[1] - target[1]) ** 2)
        (d0 <= d1).must_equal(true, "#{d0} <= #{d1} should have been true")
        r1
      end
    end
    
    def brute_force(point, data)
      res = @data.map do |p2|
        euc = Math.sqrt((p2[:point][0] - point[:point][0])**2.0 + (p2[:point][1] - point[:point][1])**2.0)
        [p2, euc]
      end
      return res.sort {|a, b| a.last <=> b.last}[0..9].map{|r| r.first}
    end
    
    it "retrieve the same results as a brute force approach" do
      msgs = []
      @data.each do |p|
        brute_force_result = brute_force(p, @data)
        nn_result = @index.nearest(p[:point], :limit => 10)
        (nn_result.map{|r| r[:point]}).must_equal(brute_force_result.map{|r| r[:point]})
      end
      must_be_empty(msgs)
    end
  end
end