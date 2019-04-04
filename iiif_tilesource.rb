src_lines = File.readlines('spotlight14032019_11.sql')

File.open("spotlight14032019_11-new.sql", "w") do |f|
  src_lines.each do |line|
    if id = line.scan(/^\((\d{1,})/).first #find ID
      id = id.first
      region = line.match(/,(\d*),(\d*),(\d*),(\d*)/).captures
      region.map!(&:to_i)
      line = line.insert(-4, "#{region[0]},#{region[1]},#{region[2]},#{region[3]},NULL,NULL,NULL,/images/#{id}/info.json")
    end
      f.puts line
  end
end
