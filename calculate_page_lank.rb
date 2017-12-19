require 'mysql2'
require 'matrix'

#######################

class Matrix
  def []=(i,j,x)
    @rows[i][j]=x
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

	def insert(client,m_n, u, t, b, c_n, e1, e5)
		client.query(
			" INSERT INTO crawler_raw_data (
				  media_name
				, url
				, title
				, body
				, crawler_name
				, etc1
				, etc5
				)
			VALUES(
				\"#{m_n}\"
				,\"#{u}\"
				,\"#{t}\"
				,\"#{b}\"
				,\"#{c_n}\"
				,\"#{e1}\"
				,\"#{e5}\"
				)
			 "
		)
	end
end


#######################
@client = Mysql2::Client.new(:host => "", :username => "", :password => "", :database => "")

mtxN = 1094

cnt = 1
results.each do |mtx|

	b = Matrix.zero(mtxN)
	
	b[mtx["pre"] - 1, mtx["post"] -1 ] = mtx["Bij"] / mtx["sumBij"]
	cnt = cnt + 1
	puts cnt
end


if mtxN^2 = cnt then
	a = b
	b = b.t

	A = b
	D = b.eigensystem.d
	u = b.eigensystem.eigenvectors
	ut = Matrix[u[0]]

	puts "#eigenValue##########"
	puts D[0,0]
	puts "#eigenVectors##########"
	puts ut * a
end
