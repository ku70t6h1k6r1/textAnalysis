# -*- coding: utf-8 -*-
require 'natto'
require 'mysql2'

#######################

class SqlSet
	def select(client)
		client.query(
			"
				SELECT data.serial, data.title
				FROM `crawler_data_cleaned` data
			"
		)
	end


	def insert(client,a_id,w_idx,w,pos,pos1,pos2,pos3,etc1,etc2,etc3,etc4,etc5)
		client.query(
			" INSERT INTO test_title_mecab (
				article_id
				, word_index
				, word
				, pos
				, pos_cat1
				, pos_cat2
				, pos_cat3
				, etc1
				, etc2
				, etc3
				, etc4
				, etc5
				)
			VALUES(
				,a_id
				,w_idx
				,\"#{w}\"
				,\"#{pos}\"
				,\"#{pos1}\"
				,\"#{pos2}\"
				,\"#{pos3}\"
				,\"#{etc1}\"
				,\"#{etc2}\"
				,\"#{etc3}\"
				,\"#{etc4}\"
				,\"#{etc5}\"
				)
			 "
		)
	end
end


#######################
@client = Mysql2::Client.new(:host => "", :username => "", :password => "", :database => "")

@sql = SqlSet.new
titles = @sql.select(@client)

titles.each do |title|
	a_id = 0
	,w_idx = 0
	,w = ""
	,pos = ""
	,pos1 = ""
	,pos2 = ""
	,pos3 = ""
	,etc1 = ""
	,etc2 = ""
	,etc3 = ""
	,etc4 = ""
	,etc5 = ""
	
	begin
		a_id = title["serial"]
		
		natto = Natto::MeCab.new
		i = 0
		natto.parse(title) do |n|
		  feature = []
		  feature = n.feature.split(",")
		  
		  w_idx = i
		  w = n.surface
		  pos = feature[0]
		  pos1 = feature[1]
		  pos2 = feature[2]
		  pos3 = feature[3]
		  etc1 = feature[4]
		  etc2 = feature[5]
		  etc3 = feature[6]
		  etc4 = feature[7]
		  etc5 = feature[8]
		  
		  @sql.insert(a_id, w_idx, w, pos, pos1, pos2, pos3, etc1, etc2, etc3, etc4, etc5)
		  
		  i = i + 1
		end
	rescue => e
	end


end
