#!/usr/bin/ruby
#
# Given a stream of numbers, print out a numerical and graphical histogram.
# Idea and some parts borrowed from the neat conplot tool.
# Available under the Apache 2.0 License
# Copyright Steve Jenson <stevej@pobox.com>

module ConHist
  # stolen from the stdlib docs.
  class Xs                # represent a string of 'x's
    include Comparable
    attr :length
    def initialize(n)
      @length = n
    end
    def succ
      Xs.new(@length + 1)
    end
    def <=>(other)
      @length <=> other.length
    end
    def to_s
      sprintf "%2d #{inspect}", @length
    end
    def inspect
      'x' * @length
    end
  end

  class Print
    # numbers is an Array of Numbers to generate a histogram for.
    def initialize(sample)
      @bins = []
      @bin_hash = {}
      @sample = sample
      @nbins = num_bins(@sample.max, @sample.min)

      pick_bins(@sample)
      collate(@sample)
    end

    def pick_bins(sample)
      # Now start from max and add nbins to sample.max and put each adderand into @bins.
      (sample.min..sample.max).step((sample.length / @nbins).ceil) { |x| @bins.push x }
    end

    # if max-min is under 30, just use them as buckets, otherwise use sturges formula
    def num_bins(max, min)
      n = (max - min) + 1
      if n < 30
        n
      else
        sturges(n)
      end
    end

    #  sturges formula for determining the optimal number of buckets.
    def sturges(n)
      (Math.log(n) + 1).ceil
    end

    # puts each item in the sample into the correct bucket.
    def collate(sample)
      sample.each do |item|
        @bins.each do |bin_id|
          if item <= bin_id
            bin = @bin_hash[bin_id]
            if bin
              bin.push item
              @bin_hash[bin_id] = bin
            else
              @bin_hash[bin_id] = [item]
            end
            break
          end
        end
      end
    end

    def print_console
      puts "Number of Bins: #{@nbins}"
      puts "Absolute Distribution"
      @bin_hash.keys.sort.each do |k|
        puts "#{k} => #{@bin_hash[k].length}"
      end
      puts "Graphical Distribution"
      @bin_hash.keys.sort.each do |k|
        puts "#{k}| #{Xs.new(((@bin_hash[k].length.to_f / @sample.length.to_f) * 70)).inspect}"
      end
    end
  end
end

if $0 == __FILE__
  numbers = $stdin.readlines.map do |l|
    if l =~ /^\s*$/
      nil
    else
      begin;  l.to_f
      rescue; nil
      end
    end
  end.compact
  if numbers.empty?
    puts "No inputs."
    exit
  end
  plot = ConHist::Print.new numbers
  plot.print_console
end

