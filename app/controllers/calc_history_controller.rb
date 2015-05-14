class CalcHistoryController < ApplicationController

  def register_uuid(client_uuid)
    unless(UuidTable.where(:uuid => client_uuid).exists?) then
        new_uuid = UuidTable.new(:uuid => client_uuid)
        new_uuid.save
    end
  end 

  def history_calculate(uuid,aid,pid)
    print("uuid : #{uuid}")
    event_aids = Newsarticles.where(:pid => pid).select(:aid)


  end

  def calc_pol(aid, event_aids)
  	ori_scores = Positivescore.find_by(aid).select(p_score)

  	event_aids.each{|each_aid|
  		if(aid != each_aid) then
  			scores = Positivescore.find_by(each_aid).select(p_score)
        
  		end
  	}
  end

  #文字列をHashへ変換
  def string2hash
    hash = []
  	self.delete("]","[") #先頭と最後尾の[]を削除
  	key_values = self.split(",") #key=valueの配列を確保
    #=で仕切られた部分を分離してkeyとvalueへ
    key_values.each {|key_value|
      set = key_value.split("=")
      hash.push(set[0],set[1])
      }
    return hash
  end

  #文字列をリストへ変換
  def string2list
    list = []
    self.delete("]","[") #先頭と最後尾の[]を削除
    list = self.split(",") #key=valueの配列を確保
    return(list)
  end

end
