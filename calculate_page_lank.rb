require 'mysql2'
require 'matrix'

#######################

class Matrix
  def []=(i,j,x)
    @rows[i][j]=x
  end
end

class SqlSet
	def select(client)
		client.query(
			"
			SELECT 
				tbl1.pre
				,tbl1.post
				,tbl1.Bij
				,tbl2.sumBij
			FROM crawler.title_mecab_pos_3gram_matrix tbl1
			LEFT OUTER JOIN
			(
				SELECT pre, SUM(Bij) as sumBij
				FROM crawler.title_mecab_pos_3gram_matrix
				GROUP BY pre
			)tbl2 
			ON tbl1.pre = tbl2.pre
			ORDER BY tbl1.pre, tbl1.post ASC
			"
		)
	end

	def insert(client,pagerank)
		client.query(
			" INSERT INTO  title_mecab_pos_3gram_matrix_PageRank(
				  pagerank
				)
			VALUES(
				#{pagerank}
				)
			 "
		)
	end
end


#######################
@client = Mysql2::Client.new(:host => "", :username => "", :password => "", :database => "")

mtxN = 1094

@sql = SqlSet.new
results = @sql.select(@client)

cnt = 1

b = Matrix.zero(mtxN)

results.each do |mtx|	
	b[mtx["pre"] - 1, mtx["post"] -1 ] = mtx["Bij"] / mtx["sumBij"]
	cnt = cnt + 1
	puts cnt
end


#if mtxN^2 == cnt then
	a = b
	b = b.t

	A = b
	D = b.eigensystem.d
	u = b.eigensystem.eigenvectors
	ut = Matrix[u[0]]

	puts "#eigenValue##########"
	puts D[0,0]
	puts "#eigenVectors##########"
	x = ut * a
	puts x

x.each do |xi|
	@sql.insert(@client,xi)
end
	
#end
