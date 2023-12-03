#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-

# number of pages
N=100

# max number of links in a page
LMAX=10

#N=10
#LMAX=3

out = File.open("matrix.txt", "w")
out.puts(N)

N.times do |i|
  # no dangling nodes
  numlinks=rand(LMAX)+1
  print "generating page %i [%i]" % [i, numlinks]
  out.write(numlinks)
  generated_links=0
  h={}
  while generated_links < numlinks and generated_links < N do
    j=rand(N)
    if j!=i and not h[j] then
      h[j]=1
      generated_links+=1
      out.write(' ',j)
      STDOUT.write(' ',j)
      #puts j
    end
  end
  out.puts
  puts
end

out.close

