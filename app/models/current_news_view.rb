class CurrentNewsView < ActiveRecord::Base
	self.primary_key = :aid
	#複合キーを持つための条件
	has_many :histories, foreign_key: :aid
	#クライアントに送る記事の尺度の見分けに用いるkind
	#テーブルに実際は無いが、仮想的な属性
	attr_accessor :kind

	has_one :polarity, foreign_key: :aid
	has_one :coverage, foreign_key: :aid
	has_one :detail, foreign_key: :aid

	#current_news_viewsに含まれる記事の各scoreのdefault値を取り出す
	scope :select_default_user_score, lambda {
		select(
		"current_news_views.aid, link, current_news_views.pid, 
		polarities.score as p_score, coverages.score as c_score, details.score as d_score"
		).joins(:polarity, :coverage, :detail)}

end
