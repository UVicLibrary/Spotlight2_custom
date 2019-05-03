require 'byebug'

src_lines = File.readlines('spotlight-with-passwords.sql')

File.open("update-passwords.txt", "w") do |f|
  src_lines.each do |line|
    if line.match(/^\((\d+)\,\'\w+@\w+\.\w+\'\,\'(.+)\',NULL/)
      captures = line.match(/^\((\d+)\,\'\w+@\w+\.\w+\'\,\'(.+)\',NULL/).captures
      id = captures[1]
      password = captures[2].split("'")[0] if captures[2]
      update_string = "UPDATE `users` SET encrypted_password='#{password}' WHERE id=#{id};"
      f.puts update_string
    # puts line unless line.include? "guest"
    # f.puts line unless line.include? "guest"
    end
  end
end
