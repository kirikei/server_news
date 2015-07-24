object false
node(:result_code){"success"}
node(:message){""}
if(@links.length != 0) then
	child @links, :root => :result, :object_root => false do
		attributes :aid, :link, :kind
	end
else
	node(:result){@links}
end
#childでもrootの名前変更可能
