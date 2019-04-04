src_lines = File.readlines('spotlight23-deleted.sql')

File.open("spotlight23-new.sql", "w") do |f|
  src_lines.each do |line|
    f.puts line unless line.include? "guest"
  end
end
