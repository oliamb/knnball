KnnBall Instruction
===================

KnnBall is a Ruby library that optimize the search of the nearest 
point given another point as input. Each point is associated to a value,
this way the library acts as an index for multidimensional data like
geolocation.


Usage
-----

    require 'knnball'
    
    data = [
    	{:id => 1, :coord => [6.3299934, 52.32444]},
    	{:id => 2, :coord => [3.34444, 53.23259]},
    	{:id => 3, :coord => [4.22452, 53.243982]},
    	{:id => 4, :coord => [4.2333424, 51.239994]},
    	# ...
    ]

    index = KnnBall.build(data)
    
    result = index.nearest([3.43353, 52.34355])


References
----------

This code was written with the help of the following ressources:

* Alorithms In a Nutshell ; George T. Heinemann, Gary Pollice & Stanley Selkow ; O'Reilly (chapter 4 and 9)
* Python SciPy kdnn module: http://scikit-learn.sourceforge.net/modules/neighbors.html
* Five Balltree Construction Algorithms, by Stephen M. Omohundro,  http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.91.8209&rep=rep1&type=pdf

Copyright (C) 2011 Olivier Amblet <http://olivier.amblet.net>

knnball is freely distributable under the terms of an MIT license.
See LICENSE or http://www.opensource.org/licenses/mit-license.php.