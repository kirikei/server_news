# -*- encoding: utf-8 -*-
class API < Grape::API
  format :json
  #formatter :json, Grape::Formatter::Rabl
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

  # /api/v1/tid  
  resource :tid do
  	# request が来たらデータベースから tid に存在する記事のIDとlinkを返す  	
    get do
      @top_links = Newsarticles.where(:pid => nil).select(:link)
    end

    get :pol do
    	#各数値が最も高いaidを得る
      @link = []
		  pol_id = Polarity.where(:score => Polarity.maximum(:score)).select(:aid)
    	@links = Newsarticles.where(:aid => pol_id).select(:link)
      #@link = @links.first
      #ActiveRecord::Base.include_root_in_json = false
      #@link.to_json

    end

    get :cov do
      #各数値が最も高いaidを得る
      @link = []
      cov_id = Coverage.where(:score => Coverage.maximum(:score)).select(:aid)
      @links = Newsarticles.where(:aid => cov_id).select(:link)
      #@link = @links.first
      #ActiveRecord::Base.include_root_in_json = false
      #@link.to_json

    end

    get :det do
      #各数値が最も高いaidを得る
      @link = []
      det_id = Detailed.where(:score => Detailed.maximum(:score)).select(:aid)
      @links = Newsarticles.where(:aid => det_id).select(:link)
      #@link = @links.first
      #ActiveRecord::Base.include_root_in_json = false
      #@link.to_json

    end

    get :top do
      
      #@top_links.to_json({:link :tid})

    end
    # parameta difinision
  	# desc 'トップ記事の取得'
   #  params do
   #    requires :top_id, type: Integer, desc: 'Top ID'
   #    requires :link, type: String, desc: 'Top link'
   #  end
  	
  	

    get :secret do
      err401
    end
  end
end
