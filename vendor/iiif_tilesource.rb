src_lines = File.readlines('spotlight11.sql')

File.open("spotlight11-new.sql", "w") do |f|
  src_lines.each do |line|
    if line.scan(/^\((\d{1,})/)
      id = line.scan(/^\((\d{1,})/).first.first
      line = line.insert(-4, "/images/#{id}/info.json")
    end
      f.puts line
  end
end
