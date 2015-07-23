class CalcHistoryController < ApplicationController

@@pol_weight = 0.8
@@det_weight = 0.3

  #uuidの登録
  def register_uuid(client_uuid)
    ##uuid_tableに存在しないなら登録
    unless(UuidTable.where(:uuid => client_uuid).exists?) then
        new_uuid = UuidTable.new(:uuid => client_uuid)
        new_uuid.save

        #client_uuidのuser_scoresを設定
        new_uuid_scores = []
        scores = CurrentNewsView.select_default_user_score
        Rails.logger.info(scores.inspect)
        #一つ一つ列に代入して
        scores.each{|default_score|

          new_score = UserScore.new(
              :aid => default_score.aid, 
              :link => default_score.link, 
              :uuid=>client_uuid, 
              :p_score=> default_score.p_score, 
              :c_score => default_score.c_score, 
              :d_score => default_score.d_score,
              :pid => default_score.pid)

          new_uuid_scores << new_score
        }
        #一気にinsert
        UserScore.import new_uuid_scores
    end
        
  end

  #閲覧履歴の保存
  def register_history(client_uuid, read_aid, time, pid)
    new_history = History.new(:uuid => client_uuid, :aid => read_aid, :time => time, :pid=>pid)
    new_history.save
  end


  #履歴の増加に因る各尺度の再計算
  def history_calculate(uuid, pid, next_aid)
    print("再計算を行います。uuid : #{uuid}, aid : #{next_aid}\n")
    event_aids = CurrentNewsView.where(:pid => pid).select(:aid)
    hist_aids = History.where(:uuid => uuid, :pid => pid).select(:aid).uniq
    #hist_aids << next_aid
    #print("@@@@@@@count : #{hist_aids.count}\n")
    #calc_cov(hist_aids, event_aids, uuid, next_aid)
    #calc_pol(hist_aids, event_aids, uuid, next_aid)
    calc_det(next_aid, event_aids, uuid, hist_aids)
  end


  #coverageの計算
  def calc_cov(hist_aids, event_aids, uuid, next_aid)
    all_hist_entities = []

    #History全ての記事のentityを統合
     next_ent_s = MiddleScore.find_by(:aid => next_aid).entity
     all_hist_entities = string2list(next_ent_s)

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
  def calc_pol(hist_aids, event_aids, uuid, next_aid)

    all_hist_pols = {}

    next_pol_s = MiddleScore.find_by(:aid => next_aid).polarity
    all_hist_pols = string2hash(next_pol_s)
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
  def calc_det(next_aid, event_aids, uuid, hist_aids)
    #next_aidのEntity, スコアとトピック番号を取り出す
    #logger.info(hist_aids.inspect)
    #next_records = TopicScore.where(:aid => next_aid)
    all_hist_records = []#next_records
    #histtoryの全てのrecordsを結合
    #hist_aids.each{|hist_aid|
    hist_records = TopicScore.where("aid IN (?) OR aid = (?)", hist_aids, next_aid)
    all_hist_records = hist_records
    #}
    #logger.info(all_hist_records.inspect)
    #columnをHash化(entity => Hash[score])
    history_hash = sum_topic_score(all_hist_records, hist_aids, next_aid)
    #ori_entity_hash = topic_record2hash(next_records)
    #print("ori@@@@@@@@@attributes : #{ori_entity_hash}\n")

    #entityの取り出し
    history_keys = history_hash.keys
    #ori_entity_keys = ori_entity_hash.keys

    event_aids.each{|each_aid|
      #読んだ記事以外について
      if(next_aid != each_aid) then
        det_result = 0
        topics = TopicScore.where(:aid => each_aid)

        #Hash化
        entity_hash = topic_record2hash(topics)
        #print("ent+++++++++ : #{entity_hash}\n")
        #entityを取り出し
        entity_keys = entity_hash.keys

        #ori_entity_keysと合体かつ重複を省く
        all_entities = entity_keys.concat(history_keys).uniq

        #各entityについて
        all_entities.each{|key| 
          topic_hash = {}
          hist_topic_hash = {}

          if entity_keys.include?(key) then
            topic_score = entity_hash[key]
            #スコアの中身が{}だけでないならば
            if topic_score.length > 2 then
              #topicのスコアをHashとして
              topic_hash = string2hash(topic_score)
              #print("topic_hash : #{key}=>#{topic_hash} length : #{topic_score.length}\n")
            end

          end
          if history_keys.include?(key) then
            hist_topic_hash = history_hash[key]
            #スコアの中身が{}だけでないならば
            #print("ori_topic_hash : #{key}=>#{ori_topic_hash} length : #{ori_topic_score.length}\n")
           
          end

          det_result += log_calc(topic_hash, hist_topic_hash)

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

  #topic_scoreのrecordをNamed Entity=>scoreのハッシュへ
  def topic_record2hash(records)
   #logger.info(records.inspect)
    mapped_records = records.map{|record| [record.entity, record.topic]}
    return Hash[mapped_records]
  end

  #historyのrecordを纏める
  def sum_topic_score(history_records, hist_aids, next_aid)
    result_hash = {}
    #
    #nextのデータをresult_hashへ
    next_record = history_records.where(:aid => next_aid)
    #logger.info(next_record.inspect)
    hashed_next_record = topic_record2hash(next_record)
    result_hash = sum_hash_score(hashed_next_record,result_hash)
    print("result_hash_next = #{result_hash}\n")

    hist_aids.each{|hist_aid|
      if(hist_aid.aid != next_aid) then
      hist_record = history_records.where(:aid => hist_aid.aid)
      logger.info(hist_record.inspect)
      hashed_topic_records = topic_record2hash(hist_record)
      result_hash = sum_hash_score(hashed_topic_records, result_hash)      
      end
    #   hashed_topic_records.each{|entity, score|
    #     #scoreはhashに変換
    #     hashed_score = string2hash(score)
    #     if(result_hash.include?(entity)) then
    #       result_score = result_hash(entity)
    #       result_score.merge(hashed_score){|topic_num, s1, s2|
    #         s1 + s2
    #       }
    #       result_hash.store(entity, result_score)

    #     else
    #       result_hash.store(entity, hashed_score)          
    #     end
    #   }
      
     }
    print("result_hash_last = #{result_hash}\n")
    return result_hash
  end

  #各aidのtopic_scoreを今までのものと合算
  def sum_hash_score(hashed_topic_records, result)
    hashed_topic_records.each{|entity, score|
        #scoreはhashに変換
        hashed_score = string2hash(score)
        if(result.include?(entity)) then
          result_score = result[entity]
          result_score.merge(hashed_score){|topic_num, s1, s2|
            s1 + s2
          }
          result.store(entity, result_score)

        else
          result.store(entity, hashed_score)          
        end
      }
      return result  
  end

end
