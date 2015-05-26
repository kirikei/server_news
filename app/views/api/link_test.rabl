collection @links, :object_root => false
node(:result_code){"success"}
node(:message){""}
node(:result) do 
|links| {aid: links.aid, link: links.link, kind: links.kind}
end

