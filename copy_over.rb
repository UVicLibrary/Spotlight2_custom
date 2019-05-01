src_lines = File.readlines('spotlight14032019_23_all_users.sql')

File.open("spotlight23-new.sql", "w") do |f|
  src_lines.each do |line|
    puts line unless line.include? "guest"
    f.puts line unless line.include? "guest"
  end
end
