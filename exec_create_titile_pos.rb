require './create_title_pos.rb'

100.times{
	puts "#################################"
	title = Title.new	
	puts title.totalPageRank
	puts title.titlePos
	puts title.title
}
