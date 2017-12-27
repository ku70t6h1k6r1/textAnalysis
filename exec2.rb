# -*- coding: utf-8 -*-
require 'natto'
require 'mysql2'

#######################

class SqlSet
	def initInsert()
			query = "
				INSERT INTO body_mecab2 (
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
			VALUES "
			
			return query
	end

	def addValues(q,a_id,w_idx,w,pos,pos1,pos2,pos3,etc1,etc2,etc3,etc4,etc5)
		q += "
			(
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
		return q
	end

	def select(client)
		client.query(
			"
				SELECT data.serial, data.title
				FROM `crawler_data_cleaned` data
				ORDER BY serial ASC;
			"
		)
	end


	def insert(client, query)
		client.query(query)
	end
end


#######################
account = Id.new
	
@client = Mysql2::Client.new(:host => account.ip, :username => account.user, :password => account.pass, :database => account.db)
@sql = SqlSet.new
titles = @sql.select(@client)

titles.each do |title|
	
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
		puts a_id
		natto = Natto::MeCab.new
		i = 0
		
		query = @sql.initInsert
		
		natto.parse(title["body"]) do |n|
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
		  
		  query += @sql.addValues(query,a_id, w_idx, w, pos, pos1, pos2, pos3, etc1, etc2, etc3, etc4, etc5)
		  query += ","
		  
		  i = i + 1
		end
		  begin
		  	query = query.slice(0, query.length - 2)
		  	@sql.insert(@client,query)
		  rescue => e
			puts e
		  end
	rescue => e
		puts e
	end
end
