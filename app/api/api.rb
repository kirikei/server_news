# -*- encoding: utf-8 -*-
class API < Grape::API
  format :json
  formatter :json, Grape::Formatter::Rabl
  default_format :json
  # /api
  prefix 'api'
  # /api/vi
  version 'v1', using: :path

  helpers do
    def dummy_name
      "dummy"
    end
    def err401
      error!('401 Unauthorized', 401) 
    end
  end

  # /api/v1/top_arts 
  resource :top_arts do
  	# request が来たらデータベースから tid に存在する記事のIDとlinkを返す
    desc 'category'
    #クライアントから受け取るパラメータの定義
    # params do
    #   requires :category, type: String, desc: 'category'
    # end

    #rablでのJson定義を用いてGetする
    get '/', rabl: 'api/top_art' do
      @top_links = Newsarticles.where(:pid => nil)#, :category => nil)
      #カテゴリーをキーにハッシュ化
      #@top_links.to_json
    end

    get :secret do
      err401
    end

  end

  # /api/v1/links 
  resource :links do
    desc 'links'
    #各数値が最も高いaidを得る
    get '/', rabl: 'api/link' do
      @links = []
      #尺度の値が最も大きな記事IDを尺度毎にとる
		  pol_id = Polarity.where(:score => Polarity.maximum(:score)).select(:aid)
      cov_id = Coverage.where(:score => Coverage.maximum(:score)).select(:aid)
      det_id = Detail.where(:score => Detail.maximum(:score)).select(:aid)
      det_link = Newsarticles.find_by(:aid => det_id)
      cov_link = Newsarticles.find_by(:aid => cov_id)
    	pol_link = Newsarticles.find_by(:aid => pol_id)

      #kindを更新し、どの尺度の記事か見分けられるように
      det_link.update_attribute(:kind, 'deep') 
      cov_link.update_attribute(:kind, 'wide')
      pol_link.update_attribute(:kind, 'opp')

      #linkに入れる
      @links.push(det_link)
      @links.push(cov_link)
      @links.push(pol_link)

      @links.to_json

    end

    get :secret do
      err401
    end

  end

end
