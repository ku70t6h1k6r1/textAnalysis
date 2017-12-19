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
				WHERE dt > '2017-12-09'
				ORDER BY serial ASC;
			"
		)
	end


	def insert(client,a_id,w_idx,w,pos,pos1,pos2,pos3,etc1,etc2,etc3,etc4,etc5)
		client.query(
			" INSERT INTO title_mecab (
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
				#{a_id}
				,#{w_idx}
				,\'#{w}\'
				,\"#{pos}\"
				,CASE WHEN \"#{pos1}\" = \"*\" THEN \"\" ELSE \"#{pos1}\" END
				,CASE WHEN \"#{pos2}\" = \"*\" THEN \"\" ELSE \"#{pos2}\" END
				,CASE WHEN \"#{pos3}\" = \"*\" THEN \"\" ELSE \"#{pos3}\" END
				,CASE WHEN \"#{etc1}\" = \"*\" THEN \"\" ELSE \"#{etc1}\" END
				,CASE WHEN \"#{etc2}\" = \"*\" THEN \"\" ELSE \"#{etc2}\" END
				,CASE WHEN \"#{etc3}\" = \"*\" THEN \"\" ELSE \"#{etc3}\" END
				,CASE WHEN \"#{etc4}\" = \"*\" THEN \"\" ELSE \"#{etc4}\" END
				,CASE WHEN \"#{etc5}\" = \"*\" THEN \"\" ELSE \"#{etc5}\" END
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
	puts title
	a_id = 0
	w_idx = 0
	w = ""
	pos = ""
	pos1 = ""
	pos2 = ""
	pos3 = ""
	etc1 = ""
	etc2 = ""
	etc3 = ""
	etc4 = ""
	etc5 = ""
	
	begin
		a_id = title["serial"]
		
		natto = Natto::MeCab.new
		i = 0
		natto.parse(title["title"]) do |n|
		  feature = []
		  feature = n.feature.split(",")
		  
		  w_idx = i
		  w = n.surface
		  puts w
		  pos = feature[0]
		  pos1 = feature[1]
		  pos2 = feature[2]
		  pos3 = feature[3]
		  etc1 = feature[4]
		  etc2 = feature[5]
		  etc3 = feature[6]
		  etc4 = feature[7]
		  etc5 = feature[8]
		  begin 
		  	@sql.insert(@client,a_id, w_idx, w, pos, pos1, pos2, pos3, etc1, etc2, etc3, etc4, etc5)
		  rescue => e
			puts e
		  end
		  i = i + 1
		end
	rescue => e
		puts e
	end


end
