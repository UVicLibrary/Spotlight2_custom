require 'mini_magick'

pdf = MiniMagick::Image.open "Transvestia.pdf"

MiniMagick::Tool::Convert.new do |convert|
  convert.background "white"
  convert.flatten
  convert.density 150
  convert.quality 100
  convert << pdf.pages.first.path
  convert << "png8:preview.png"
end
