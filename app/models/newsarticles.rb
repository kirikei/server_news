class Newsarticles < ActiveRecord::Base
	self.primary_key = :aid
	#複合キーを持つための条件
	has_many :histories, foreign_key: :aid
	#クライアントに送る記事の尺度の見分けに用いるkind
	#テーブルに実際は無いが、仮想的な属性
	attr_accessor :kind
end
