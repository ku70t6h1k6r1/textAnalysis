# -*- coding: utf-8 -*-
require 'natto'
require 'mysql2'
require './config/info.rb'

#######################

class SqlSet

	def select(client)
		client.query(
			"
				SELECT data.serial, data.body
				FROM `crawler_data_cleaned` data
		                
				ORDER BY serial ASC;
			"
		)
	end
end


#######################
account = Id.new
	
@client = Mysql2::Client.new(:host => account.ip, :username => account.user, :password => account.pass, :database => account.db)
@sql = SqlSet.new
bodies = @sql.select(@client)

corpus = []

bodies.each do |body|
	puts body["serial"]
	begin
		natto = Natto::MeCab.new

		natto.parse(body["body"]) do |n|
		  feature = []
		  feature = n.feature.split(",")

		  etc3 = feature[6]
		  corpus.push(etc3)
		end
	rescue => e
		puts e
	end
end

output = corpus.join(" ")

File.open("/media/HD_3TB/kubota/corpus/toshidensetsu_corpus.txt", "w") do |f| 
  f.puts(output)
end

