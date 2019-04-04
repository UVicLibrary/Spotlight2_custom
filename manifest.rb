require 'json'
require 'iiif/presentation'
require 'byebug'

# require 'rest-client'
# response = RestClient.get 'http://ophelia.library.uvic.ca/spotlight/test-exhibit/catalog/1-354/manifest'#, {accept: :json}
# response = JSON.load(open("http://ophelia.library.uvic.ca/spotlight/test-exhibit/catalog/1-354/manifest.json"))#, {accept: :json}
#
# puts response
# puts response.body #this must show the JSON contents

test_array = ['test.json', 'test2.json', 'test3.json']

#Create a new manifest
seed = {
    '@id' => 'http://example.com/manifest',
    'label' => 'My Manifest'
}
# Any options you add are added to the object
manifest = IIIF::Presentation::Manifest.new(seed)

# Create sequence headers
sequence = IIIF::Presentation::Sequence.new(
  '@id'=> 'http://ophelia.library.uvic.ca/spotlight/test-exhibit/catalog/1-355/manifest',
  '@type' => 'sc:Sequence'
  )

# Returns an array of validated canvas objects
def make_canvases(file_array)
  new_array = []
  file_array.each do |file|
    # Parse twice to turn it back into a hash. See https://stackoverflow.com/questions/42494823/json-parse-returns-string-instead-of-object
    source_m = IIIF::Service.parse(JSON.parse(JSON.parse(File.read(file))))
    canvas = source_m.sequences.first.canvases.first
    resource = canvas.images.first.resource
    # Label each canvas with the manifest label if there is one
    canvas.label = source_m.label if source_m.label
    # Change widths and heights to integers so manifest will be valid
    canvas.width = canvas.width.to_i
    canvas.height = canvas.height.to_i
    # Change image resource attributes
    resource.width = resource.width.to_i
    resource.height = resource.height.to_i
    resource["@id"] = canvas["@id"]
    new_array.push(canvas)
  end
  # If Canvas doesn't have a label, assign it one (needs label to validate)
  new_array.each do |canvas|
    if canvas.label.nil?
      assigned_label = (new_array.index(canvas) + 1).to_s
      canvas.label = assigned_label
    end
  end
  return new_array
end

sequence.canvases = make_canvases(test_array)
manifest.sequences << sequence
puts manifest.to_json(pretty: true)

# m = IIIF::Service.parse(JSON.parse(JSON.parse(File.read(file))))
