# encoding: UTF-8

# Copyright (C) 2011 Olivier Amblet <http://olivier.amblet.net>
#
# knnball is freely distributable under the terms of an MIT license.
# See LICENSE or http://www.opensource.org/licenses/mit-license.php.

require 'minitest/autorun'
require 'knnball'

module KnnBall
  
  describe ResultSet do
    
    describe "default state" do
      
      before :each do
        @rs = ResultSet.new
      end
      
      it "has a 10 items limit" do
        assert_equal 10, @rs.limit
      end
      
      it "has no barrier value" do
        assert_nil @rs.barrier_value
      end
      
      it "has an empty items array" do
        assert_equal [], @rs.items
      end
      
      it "accept any value" do
        @rs.eligible? 12
      end
    end
    
    describe "fix the limit" do
      
      before :each do
        @rs = ResultSet.new :limit => 1
      end
      
      it "has a 1 items limit" do
        assert_equal 1, @rs.limit
      end
      
      it "has no barrier value" do
        assert_nil @rs.barrier_value
      end
      
      it "has an empty items array" do
        assert_equal [], @rs.items
      end
      
      it "accept any value" do
        assert @rs.eligible?(12)
      end
      
      it "accept only one value" do
        assert @rs.add(12, '12')
        assert ! @rs.eligible?(13)
        assert @rs.eligible?(2)
        assert @rs.add(2, '2')
        assert_equal ['2'], @rs.items
      end
    end
    
    
    describe "first value" do
      before :each do
        @rs = ResultSet.new
        @rs.add(2, 'AA')
      end
      
      it "set its barrier value to the first added value" do
        assert_equal 2, @rs.barrier_value
      end
      
      it "add the item to the item list" do
        assert_equal ['AA'], @rs.items
      end
      
      it "accept any value" do
        @rs.eligible? 12
      end
    end
    
    describe "up to the limit" do
      before :each do
        @rs = ResultSet.new
        @rs.add(5, '5')
        @rs.add(2, '2')
        @rs.add(10, '10')
        @rs.add(5, '5')
        @rs.add(3, '3')
        @rs.add(4, '4')
        @rs.add(5, '5')
        @rs.add(1, '1')
        @rs.add(5, '5')
        @rs.add(5, '5')
      end
      
      it "set its barrier value to the first added value" do
        assert_equal 10, @rs.barrier_value
      end
      
      it "add the item to the item list" do
        assert_equal ['1', '2', '3', '4', '5', '5', '5', '5', '5', '10'], @rs.items
      end
      
      it "successfuly add an item that should replace the last one" do
        @rs.add(9, '9')
        assert_equal ['1', '2', '3', '4', '5', '5', '5', '5', '5', '9'], @rs.items
      end
    end
    
    describe "break the limit" do
      before :each do
        @rs = ResultSet.new
        @rs.add(5, '5')
        @rs.add(2, '2')
        @rs.add(10, '10')
        @rs.add(5, '5')
        @rs.add(3, '3')
        @rs.add(4, '4')
        @rs.add(5, '5')
        @rs.add(1, '1')
        @rs.add(5, '5')
        @rs.add(5, '5')
        
        @rs.add(11, '11')
        @rs.add(-1, '-1')
        @rs.add(6, '6')
        @rs.add(4, '4')
        @rs.add(0, '0')
      end
      
      it "set its barrier value to the first added value" do
        assert_equal 5, @rs.barrier_value
      end
      
      it "add the item below the limit to the item list" do
        assert_equal ['-1', '0', '1', '2', '3', '4', '4', '5', '5', '5'], @rs.items
      end
      
      it "refuse big values" do
        assert ! @rs.eligible?(12)
        assert ! @rs.eligible?(5)
      end
      
      it "accept smaller value" do
        assert @rs.eligible? -2
        assert @rs.eligible? 4
      end
    end
  end
end