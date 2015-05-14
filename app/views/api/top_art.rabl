node (:result_code) {"success"}
node (:message){""}
node (:result) {@top_links.group_by {|x| x['category']}.map {|category, items| {category: category,  items: items}}}

#collection @top_links, :root => :result
#attributes :aid, :link, :summary, :image