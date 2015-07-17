class UserScore < ActiveRecord::Base

	#渡されたuuidでhistoryに含まれないレコードを返す
	#引数はprint(””)と同じ記法で
	scope :not_in_history, ->(uuid, root_aid, next_aid) do
		where <<-SQL
		PID = '#{root_aid}'
		AND
		UUID = '#{uuid}'
		AND
		AID NOT IN
		 (SELECT AID FROM HISTORIES WHERE UUID = '#{uuid}')
		AND
		AID <> '#{next_aid}'
		SQL
	end
	 

end
