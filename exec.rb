# -*- coding: utf-8 -*-
require 'natto'

txt = 'うむ、動けよ、動け、動いておくんなまし。なんじはまさに例えばであるように思うなりにけり安倍晋三総理大臣。えーと、トホホ'
serial = 1000

natto = Natto::MeCab.new
i = 0
natto.parse(txt) do |n|
  feature = []
  feature = n.feature.split(",")
  feature = feature.slice(0..3).select{|x| x != "*"}
  feature = feature.join(",")

  puts "#{serial}/#{i}/#{n.surface}/#{feature}"
  i = i + 1
end
