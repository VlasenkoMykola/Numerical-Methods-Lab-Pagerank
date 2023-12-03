#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-

class SquareMatrix
  attr_reader :size, :data

  def initialize(size, data)
    raise ArgumentError, "Invalid data size" unless data.size == size**2
    @size = size
    @data = data
  end

  def self.zeroMatrix(size)
    new(size, Array.new(size*size, 0))
  end

  def self.constMatrix(size, const)
    new(size, Array.new(size*size, const))
  end

  def self.from_array(size, array)
    new(size, array)
  end

  def self.from_nested_array(array)
    size = array.size
    data = array.flatten
    new(size, data)
  end

  def size
    @size
  end

  def to_a
    data.each_slice(size).to_a
  end

  def ==(other)
    size == other.size && data == other.data
  end

  def multiply_with_matrix(other_matrix)
    raise ArgumentError, "Incompatible matrix sizes for multiplication" unless size == other_matrix.size

    result_data = Array.new(size**2, 0)

    size.times do |i|
      size.times do |j|
        size.times do |k|
          result_data[i * size + j] += self[i, k] * other_matrix[k, j]
        end
      end
    end

    SquareMatrix.new(size, result_data)
  end

  def multiply_with_vector(vector)
    raise ArgumentError, "Incompatible vector size for multiplication" unless size == vector.size

    result_data = Array.new(size, 0)

    size.times do |i|
      size.times do |j|
        result_data[i] += self[i, j] * vector[j]
      end
    end

    result_data
  end

  def multiply_with_scalar(scalar)
    result_data = data.map { |element| element * scalar }
    SquareMatrix.new(size, result_data)
  end

  def *(other)
    case other
    when SquareMatrix
      multiply_with_matrix(other)
    when Array
      multiply_with_vector(other)
    when Numeric
      multiply_with_scalar(other)
    else
      raise ArgumentError, "Unsupported operand type for multiplication"
    end
  end

  def +(other_matrix)
    raise ArgumentError, "Incompatible matrix sizes for addition" unless size == other_matrix.size

    result_data = data.zip(other_matrix.data).map { |a, b| a + b }
    SquareMatrix.new(size, result_data)
  end

  def [](row, col)
    data[row * size + col]
  end

  def []=(row, col, value)
    raise ArgumentError, "Invalid indices" unless (0...size).cover?(row) && (0...size).cover?(col)
    data[row * size + col] = value
  end

  def norm
    acc = 0
    size.times do |i|
      size.times do |j|
        acc += self[i, j]**2
      end
    end
    Math.sqrt(acc)
  end
end

class Array
  def norm
    Math.sqrt(self.inject(0) { |sum, x| sum + x**2 })
  end
end

def read_page_graph(infile)
  f = File.open(infile, "r");
  # number of pages
  n=f.readline.to_i
  puts n
  matrix=SquareMatrix.zeroMatrix(n);
  print "loading page graph:"
  (0...n).each do |i|
    in_array=f.readline.chomp!.split(" ");
    numlinks=in_array.shift.to_i
    page_weight=1.0/numlinks
    print " %i [%i:%f]" % [i, numlinks, page_weight]
    in_array.each do |j|
      matrix[i, j.to_i]=page_weight
    end
  end
  puts
  f.close
  matrix
end




infile="matrix.txt"
infile=ARGV[0] if ARGV.size > 0
matrixA=read_page_graph(infile);
#p a

# the value of m originally used by Google is reportedly 0.15
m=0.15
n=matrixA.size
matrixM= matrixA * (1-m) + SquareMatrix.constMatrix(n, 1.0/n) * m

# https://en.wikipedia.org/wiki/Power_iteration

def power_iteration(n, aMatrix, num_iterations)
  # Ideally choose a random vector
  # To decrease the chance that our vector
  # Is orthogonal to the eigenvector
  b_k = Array.new(n) { rand(10.0) };

  num_iterations.times do
    # calculate the matrix-by-vector product Ab
    b_k1 = aMatrix * b_k

    # calculate the norm
    b_k1_norm = b_k1.norm

    # re normalize the vector
    b_k = b_k1.map { |x| x / b_k1_norm }
  end
  b_k
end
num_iterations=10
puts "Calculating eigenvalue using %i iterations:" % [num_iterations]
p power_iteration(n, matrixM, num_iterations)

