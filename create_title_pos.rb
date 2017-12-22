require 'mysql2'
require 'matrix'
require './config/info.rb'


#######################

class Matrix
  def []=(i,j,x)
    @rows[i][j]=x
  end
end

class Dice
	def shake(array)
		array = ( Vector.elements(array)  / array.inject(:+) ).to_a
		random = Random.new.rand(1e8)/1e8.to_f		
		
		sumVal = 0.0
		i =  0
		array.each do |val|
			sumVal = val + sumVal
			if sumVal  >=  random then
				break
			else
				i += 1
			end
		end
		
		return i
	end
end

class SqlSet
	def selectFirst(client)
		client.query(
			"
				SELECT 
				nodes.pre as pre_index
				,pos.pos1_name as pre1
				,pos.pos2_name as pre2
				,pos.pos3_name as pre3
				,nodes.post as post_index
				,pos2.pos1_name as post1
				,pos2.pos2_name as post2
				,pos2.pos3_name as post3
				,pr2.pagerank as pre_pagerank
				,pr.pagerank as post_pagerank
				FROM crawler.title_mecab_pos_3gram_matrix nodes
				LEFT OUTER JOIN crawler.title_mecab_pos_3gram_matrix_PageRank pr 
				ON nodes.post = pr.pos_index
				LEFT OUTER JOIN crawler.title_mecab_pos_3gram_matrix_PageRank pr2
				ON nodes.pre = pr2.pos_index
				LEFT OUTER JOIN 
				crawler.control_pos_3gram pos
				ON pos.pos_index = nodes.pre
				LEFT OUTER JOIN 
				crawler.control_pos_3gram pos2
				ON pos2.pos_index = nodes.post
				WHERE nodes.flg != 0
				ORDER BY pr2.pagerank
			"
		)
	end

	def select(client, pos_index)
		client.query(
			"
				SELECT 
				nodes.pre as pre_index
				,pos.pos1_name as pre1
				,pos.pos2_name as pre2
				,pos.pos3_name as pre3
				,nodes.post as post_index
				,pos2.pos1_name as post1
				,pos2.pos2_name as post2
				,pos2.pos3_name as post3
				,pr2.pagerank as pre_pagerank
				,pr.pagerank as post_pagerank
				FROM crawler.title_mecab_pos_3gram_matrix nodes
				LEFT OUTER JOIN crawler.title_mecab_pos_3gram_matrix_PageRank pr 
				ON nodes.post = pr.pos_index
				LEFT OUTER JOIN crawler.title_mecab_pos_3gram_matrix_PageRank pr2
				ON nodes.pre = pr2.pos_index
				LEFT OUTER JOIN 
				crawler.control_pos_3gram pos
				ON pos.pos_index = nodes.pre
				LEFT OUTER JOIN 
				crawler.control_pos_3gram pos2
				ON pos2.pos_index = nodes.post
				WHERE nodes.flg != 0
				AND nodes.pre = #{pos_index}
				ORDER BY pr2.pagerank
			"
		)
	end

	def selectFirstWords(client,pos_index)
			client.query(
			"
				SELECT 
				CONCAT(pos1,\'/\',pos2,\'/\',pos3) as pos
				,CONCAT(word1,\'/\',word2,\'/\',word3) as word
				FROM crawler.title_mecab_pos_3gram
				WHERE pos_index = #{pos_index};
			"
			)
	end

	def selectWords(client,pos_index)
			client.query(
			"
				SELECT 
				pos3 as pos
				,word3 as word
				FROM crawler.title_mecab_pos_3gram
				WHERE pos_index = #{pos_index};
			"
			)
	end
	
end


#######################

class Title
	def initialize()
		account = Id.new
	
		@client = Mysql2::Client.new(:host => account.ip, :username => account.user, :password => account.pass, :database => account.db)
		@sql = SqlSet.new
		results = @sql.selectFirst(@client)

		#TitlePsOS
		titlePsOS = []

		posIndex = []
		posPageRank =[]
		dice = Dice.new

		results.each do |row|	
			posIndex.push(row["pre_index"])
			posPageRank.push(1.0 / row["pre_pagerank"])
		end

		curretIndex = posIndex[dice.shake(posPageRank)]
		titlePsOS.push(curretIndex)

		loop{
			postPosIndex = []
			postPosPageRank =[]
			dice2 = Dice.new
			
			read = @sql.select(@client, curretIndex)
			read.each do |row|
				postPosIndex.push(row["post_index"])
				postPosPageRank.push(row["post_pagerank"])
			end
			if postPosIndex.length > 0 then
				curretIndex = postPosIndex[dice2.shake(postPosPageRank)]
				titlePsOS.push(curretIndex)
				puts curretIndex
			else
				break
			end
		}

		@title = []
		@titlePos = []
	
		count = 0
		titlePsOS.each do |pos|
			if count == 0 then
				read = @sql.selectFirstWords(@client, pos)
			else
				read = @sql.selectWords(@client, pos)
			end
			
			words = []
			psos = []
			read.each do |row|
				words.push(row["word"])
				psos.push(row["pos"])
			end
			@title.push(words[Random.new.rand(words.length)])
			@titlePos.push(psos[0])
			count += 1
		end
	end
	
	def title
		output = @title.join("/")
		return output
	end
	
	def titlePos
		output = @titlePos.join("/")
		return output
	end
end
