object false
node(:result_code){"success"}
node(:message){""}
child @links, :root => :result, :object_root => false do
	attributes :aid, :link, :kind
end
#childでもrootの名前変更可能
