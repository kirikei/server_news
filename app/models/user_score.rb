class UserScore < ActiveRecord::Base

	#渡されたuuidでhistoryに含まれないレコードを返す
	#引数は””と同じ記法で
	scope :not_in_history, ->(uuid, root_aid) do
		where <<-SQL
		PID = '#{root_aid}'
		AND
		UUID = '#{uuid}'
		AND
		AID NOT IN
		 (SELECT AID FROM HISTORIES WHERE UUID = '#{uuid}')
		SQL
	end
end
