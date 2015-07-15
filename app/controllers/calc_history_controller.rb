class CalcHistoryController < ApplicationController

@@pol_weight = 0.8
@@det_weight = 0.3

  #uuidの登録
  def register_uuid(client_uuid)
    unless(UuidTable.where(:uuid => client_uuid).exists?) then
        new_uuid = UuidTable.new(:uuid => client_uuid)
        new_uuid.save
    end
  end

  #閲覧履歴の保存
  def register_history(client_uuid, read_aid, time, pid)
    new_history = History.new(:uuid => client_uuid, :aid => read_aid, :time => time, :pid=>pid)
    new_history.save
  end


  #履歴の増加に因る各尺度の再計算
  def history_calculate(uuid, read_aid, pid)
    print("再計算を行います。uuid : #{uuid}, aid : #{read_aid}\n")
    event_aids = CurrentNewsView.where(:pid => pid).select(:aid)
    hist_aids = History.where(:uuid => uuid, :pid => pid).select(:aid).uniq
    #print("@@@@@@@count : #{hist_aids.count}\n")
    calc_cov(hist_aids, event_aids, uuid)
    calc_pol(hist_aids, event_aids, uuid)
    calc_det(read_aid, event_aids, uuid, hist_aids)
  end


  #coverageの計算
  def calc_cov(hist_aids, event_aids, uuid)
    all_hist_entities = []

    #History全ての記事のentityを統合
    hist_aids.each{|hist_aid|
      logger.info(hist_aid.aid.inspect)
      hist_entity_s = MiddleScore.find_by(:aid => hist_aid.aid).entity
      hist_entities = string2list(hist_entity_s)
      #print("hist_en : #{hist_entities}\n")
      all_hist_entities = all_hist_entities | hist_entities
    }
    #print("all_en : #{all_hist_entities}\n")
    #読んだ記事以外について
    event_aids.each{|each_aid|
      if(!hist_aids.include?(each_aid)) then
        cov_result = 0
        entity_s = MiddleScore.find_by(:aid => each_aid).entity
        rel_score = MiddleScore.find_by(:aid => each_aid).relevance
        entities = string2list(entity_s)
        #エンティティの集合演算
        cov_result = rel_score * (entities - all_hist_entities).length
        UserScore.where(:aid => each_aid, :uuid => uuid).update_all(:c_score => cov_result)

      end
    }

  end

  #polarityの計算
  def calc_pol(hist_aids, event_aids, uuid)

    all_hist_pols = {}
    #読んだ記事のスコアとkeyを取り出す
    hist_aids.each{|hist_aid|
      hist_pol_s = MiddleScore.find_by(:aid => hist_aid.aid).polarity
      hist_pols = string2hash(hist_pol_s)
      #print("Hist_pols : #{hist_pols}\n")
      hist_pols.each{|key, value|
        #既にkeyを含んでいるなら
        if(all_hist_pols.include?(key)) then
          all_value = all_hist_pols[key]
          all_hist_pols.store(key, value + all_value)
        else
          all_hist_pols.store(key, value)
        end
      }
    }
    #print("all_Hist_pols : #{all_hist_pols}\n")
    all_hist_keys = all_hist_pols.keys
    
  	event_aids.each{|each_aid|
      #読んだ記事以外について
  		if(!hist_aids.include?(each_aid)) then
        pol_result = 0
  			pols_s = MiddleScore.find_by(:aid => each_aid).polarity
        pols = string2hash(pols_s)
        keys = pols.keys
        #ori_keyと合体かつ重複を省く
        keys.concat(all_hist_keys).uniq!

        #全てのentityについて
        keys.each{|key| 
          score = 0
          hist_score = 0
          if pols.include?(key) then
            score = pols[key]
          end
          if all_hist_pols.include?(key) then
            hist_score = all_hist_pols[key]
          end
          
          pol_result += (score - hist_score).abs
          }
          #UserScoreの値を更新
          UserScore.where(:aid => each_aid, :uuid => uuid).update_all(:p_score => pol_result)
  		end
  	}
  end

  #detailednessの計算
  def calc_det(read_aid, event_aids, uuid, hist_aids)
    #読んだ記事のEntity, スコアとトピック番号を取り出す
    ori_topics = TopicScore.where(:aid => read_aid)

    #columnをHash化(entity => score)
    mapped_ori_topic = ori_topics.map{|ori_topic| [ori_topic.entity, ori_topic.topic]}
    ori_entity_hash = Hash[mapped_ori_topic]
    #print("ori@@@@@@@@@attributes : #{ori_entity_hash}\n")

    #entityの取り出し
    ori_entity_keys = ori_entity_hash.keys

    event_aids.each{|each_aid|
      #読んだ記事以外について
      if(read_aid != each_aid) then
        det_result = 0
        topics = TopicScore.where(:aid => each_aid)

        #Hash化
        mapped_topic = topics.map{|rel_topic| [rel_topic.entity, rel_topic.topic]}
        entity_hash = Hash[mapped_topic]
        #print("ent+++++++++ : #{entity_hash}\n")
        #entityを取り出し
        entity_keys = entity_hash.keys

        #ori_entity_keysと合体かつ重複を省く
        all_entities = entity_keys.concat(ori_entity_keys).uniq

        #各entityについて
        all_entities.each{|key| 
          topic_hash = {}
          ori_topic_hash = {}

          if entity_keys.include?(key) then
            topic_score = entity_hash[key]
            #スコアの中身が{}だけでないならば
            if topic_score.length > 2 then
              #topicのスコアをHashとして
              topic_hash = string2hash(topic_score)
              #print("topic_hash : #{key}=>#{topic_hash} length : #{topic_score.length}\n")
            end

          end
          if ori_entity_keys.include?(key) then
            ori_topic_score = ori_entity_hash[key]
            #スコアの中身が{}だけでないならば
            if ori_topic_score.length > 2 then
              #topicのスコアをHashとして
              ori_topic_hash = string2hash(ori_topic_score)
              #print("ori_topic_hash : #{key}=>#{ori_topic_hash} length : #{ori_topic_score.length}\n")
            end
          end

          det_result += log_calc(topic_hash, ori_topic_hash)

          }
          #Historyの値を更新
          print("det_result : #{det_result}\n")
          UserScore.where(:aid => each_aid, :uuid => uuid).update_all(:d_score => det_result)
      end
    }
  end


  #文字列をHashへ変換
  def string2hash(str)
    str = str.delete("}|{") #先頭と最後尾の{}を削除
    #keyとvalueに変換
    result = str.scan(/(\w.*?)=(-*\d+\.?\d+)/).map{|k, v| [k, v.to_f] }.to_h
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
      result = 0.0

      #例外を拾ったら取りあえず0を返す
      begin
        if at_scores.length==0 && ot_scores.length == 0 then
          result = 0.0
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
            #print("nil? : #{ot_scores}\n")
            ot = ot_scores[key]

            if((at - ot) >= 0) then
              result += Math.log(((at-ot).abs/(at+ot+1))+1)   
            else
              result -= Math.log(((at-ot).abs/(at+ot+1))+1) 
            end       
          }
        end

      rescue Exception => e
        print(e)
      end

    return result

  end


end
