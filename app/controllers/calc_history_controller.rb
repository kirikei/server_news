class CalcHistoryController < ApplicationController

  #uuidの登録
  def register_uuid(client_uuid)
    unless(UuidTable.where(:uuid => client_uuid).exists?) then
        new_uuid = UuidTable.new(:uuid => client_uuid)
        new_uuid.save
    end
  end

  #閲覧履歴の保存
  def register_history(client_uuid, read_aid, time)
    new_history = History.new(:uuid => client_uuid, :aid => read_aid, :time => time)
    new_history.save
  end


  #履歴の増加に因る各尺度の再計算
  def history_calculate(uuid, read_aid, pid)
    print("uuid : #{uuid}, aid : #{read_aid}")
    event_aids = Newsarticles.where(:pid => pid).select(:aid)
    #read_aids = History.where(:uuid => uuid).select(:aid)
    calc_pol(read_aid, event_aids, uuid)
  end


  #coverageの計算
  def calc_cov(read_aid, event_aids, uuid)
    ori_entity_s = MiddleScore.find_by(read_aid).entity
    ori_entities = string2list(ori_entity_s)

    #読んだ記事以外について
    event_aids.each{|each_aid|
      if(read_aid != each_aid) then
        cov_result = 0
        entity_s = MiddleScore.find_by(each_aid).entity
        rel_score = MiddleScore.find_by(each_aid).relevance
        entities = string2list(entity_s)
        #エンティティの集合演算
        cov_result = rel_score * (entities - ori_entities).length
        UserScore.where(:aid => each_aid, :uuid => uuid).update('c_score = cov_result')

      end
    }

  end

  #polarityの計算
  def calc_pol(read_aid, event_aids, uuid)
    #読んだ記事のスコアとkeyを取り出す
  	ori_scores_s = MiddleScore.find_by(read_aid).polarity
    ori_scores = string2hash(ori_scores_s)
    ori_keys = ori_scores.keys
    
  	event_aids.each{|each_aid|
      #読んだ記事以外について
  		if(read_aid != each_aid) then
        pol_result = 0
  			scores_s = MiddleScore.find_by(each_aid).polarity
        scores = string2hash(scores_s)
        keys = scores.keys
        #ori_keyと合体かつ重複を省く
        keys.concat(ori_keys).uniq!

        #全てのentityについて
        keys.each{|key| 
          score = 0
          ori_score = 0
          if scores.include?(key) then
            score = scores[key]
          end
          if ori_scores.include?(key) then
            ori_score = ori_scores[key]
          end
          
          pol_result += (score - ori_score).abs
          }
          #Historyの値を更新
          UserScore.where(:aid => each_aid, :uuid => uuid).update('p_score = pol_result')
  		end
  	}
  end

  #detailednessの計算
  def calc_det(read_aid, event_aids, uuid)
    #読んだ記事のEntity, スコアとトピック番号を取り出す
    ori_topics = TopicScore.where(read_aid)
    #columnをHash化
    ori_entity_hash = ori_topics.attributes
    ori_entity_keys = ori_entity_hash.keys

    event_aids.each{|each_aid|
      #読んだ記事以外について
      if(read_aid != each_aid) then
        det_result = 0
        topics = TopicScore.find_by(read_aid)
        entity_hash = topics.attributes
        
        entity_keys = entity_hash.keys
        #ori_entity_keysと合体かつ重複を省く
        entity_keys.concat(ori_entity_keys).uniq!

        #各entityについて
        entity_keys.each{|key| 
          topic_hash = {}
          ori_topic_hash = {}

          if entity_keys.include?(key) then
            topic_score = entity_hash[key]
            #topicのスコアをHashとして
            topic_hash = string2hash(topic_score)
          end
          if ori_entity_keys.include?(key) then
            ori_topic_score = entity_hash[key]
            #topicのスコアをHashとして
            ori_topic_hash = string2hash(ori_topic_score)
          end
          
          det_result += log_calc(topic_hash, ori_topic_hash)

          }
          #Historyの値を更新
          UserScore.where(:aid => each_aid, :uuid => uuid).update('p_score = det_result')
      end
    }
  end


  #文字列をHashへ変換
  def string2hash(str)
    str = str.delete("}|{") #先頭と最後尾の[]を削除
    print "#{str}\n"
    #keyとvalueに変換
    result = str.scan(/(\w.+?)=(\d+\.?\d+)/).map{|k, v| [k, v.to_f] }.to_h
    return result
  end

  #文字列をリストへ変換
  def string2list(str)
    list = []
    str = str.delete("[|]") #先頭と最後尾の[]を削除
    list = str.split(", ") 
    return(list)
  end

  #詳細の差のlog計算
  def log_calc(at_scores, ot_scores)
    if at_scores.length == 0 && ot_scores.length == 0 then
      result = 0
    elsif at_scores.length == 0 then
      ot_scores.each{|key, ot|
        result -= Math.log(((ot).abs/(ot+1))+1)    
      }
    elsif ot_scores.length == 0 then
      at_scores.each{|key, at|
        result += Math.log(((at).abs/(at+1))+1)          
      }
    else
      at_scores.each{|key, at|
        ot = ot_scores[key]
        if((at-ot) >= 0) then
          result += Math.log(((at-ot).abs/(at+ot+1))+1)   
        else
          result -= Math.log(((at-ot).abs/(at+ot+1))+1) 
        end       
      }
    end
    return result
  end


end
