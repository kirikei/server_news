# -*- encoding: utf-8 -*-
class API < Grape::API
  format :json
  formatter :json, Grape::Formatter::Rabl
  default_format :json
  # /api
  prefix 'api'
  # /api/vi
  version 'v1', using: :path

  #繰り返し使うような文字やメソッドを定義しておく場所
  helpers do
    def dummy_name
      "dummy"
    end
    
    def err401
      error!('401 Unauthorized', 401) 
    end
    #記事の３つのリンクを返すActionの条件
    def check_links(action)
      if action == 'opp' || action == 'deep' || action == 'wide' then
         return(true)
      else
        return(false)
      end
    end

  end

  #------------------------例外処理---------------------------

  #パラメータが無い時の例外処理
  rescue_from Grape::Exceptions::ValidationErrors do |e|
    rack_response({result_code:'fail', massage: e.message, result:{}}.to_json, 400)
  end

  # 例外ハンドル 500(internal server error)
  rescue_from :all do |e|
    # if Rails.env.development? #環境がdevelopmentならば
    #   raise e
    # else
      rack_response({result_code:'error', message: e.message, result:{}}.to_json, 500)
    #end
  end

  #外部キーエラーが起きたとき（uuidに限定したいなぁ）
  rescue_from ActiveRecord::InvalidForeignKey do |e|
    rack_response({result_code:'fail', massage: e.message, result:{}}.to_json, 500)
  end

  #-----------------------------------------------------------

  # /api/v1/top_arts 
  resource :top_arts do

  	# request が来たらデータベースから tid に存在する記事のIDとlinkを返す
    desc 'uuid check to top_arts'

    #クライアントから受け取るパラメータの定義
    params do
       requires :uuid, type: String, desc: 'uuid'
    end

    #rablでのJson定義を用いてGetする
    post '/', rabl: 'api/top_art' do
      #uuidの登録
      uuid_reg = CalcHistoryController.new()
      uuid_reg.register_uuid(params[:uuid])      

      #top記事を持ってくる
      @top_links = Newsarticles.where(:pid => nil)
      @top_links = @top_links.select('aid','image','summary','title','category','link','pubdate')
    end

    get :secret do
      err401
    end

  end

  # /api/v1/links 
  resource :links do
    desc 'uuid check to links'
    #受け取ったjsonをカットしparamへ格納

    params do
      #jsonを拾えるか

        requires :uuid, type: String, desc: 'uuid'
        requires :read_aid, type: String, desc: '読んだ記事のaid' 
        requires :root_aid, type: String, desc: 'pid'
        requires :action, type: String, desc: 'action'
        requires :time, type: Integer, desc: '読むのにかかった時間'
        #詳細画面->詳細画面の遷移の時だけ
        optional :next_aid, type: String, desc: '次に読む記事のaid'
    end

    #各数値が最も高いaidを得る
    post '/', rabl: 'api/link' do

      action = params[:action]
      read_aid = params[:read_aid]
      client_uuid = params[:uuid]
      next_aid = params[:next_aid]
      root_aid = params[:root_aid]
      time = params[:time]

      calc_hist = CalcHistoryController.new()
      print "next_aid #{next_aid} \n"
      print "root_aid #{root_aid}\n"
      print "read_aid #{read_aid}\n"
      print "client_uuid #{client_uuid}\n"

      #historyへの登録
      if read_aid != nil then
          calc_hist.register_history(client_uuid, read_aid, time)
      end

      @links = []
      #３つのリンクのactionならば
      if check_links(action) then
        #pid = root_aidかつ尺度の値が最も大きな記事IDを尺度毎にとる
		    # pol_id = Polarity.where(:score => Polarity.maximum(:score, :conditions =>{:pid => root_aid})).select(:aid)
      #   cov_id = Coverage.where(:score => Coverage.maximum(:score, :conditions =>{:pid => root_aid})).select(:aid)
      #   det_id = Detail.where(:score => Detail.maximum(:score), :conditions =>{:pid => root_aid}).select(:aid)
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

      end

      @links.to_json
     
    end

    get :secret do
      err401

    end

  end

end
