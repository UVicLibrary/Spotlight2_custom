require 'rsolr'

# Direct connection
solr = RSolr.connect :url => 'http://localhost:8983/solr/blacklight-core'

# Spotlight needs the exhibit ID to find custom metadata fields (location is no longer a default metadata field)
exhibit_id = "test-exhibit"

query = "" #self.search.nil? ? "*:*" : self.search.gsub(',',' OR ')
res = solr.get 'select', :params => {
  :q=>query,
  :start=>0,
  :rows=>1000,
  :fl=> ["id", "spotlight_exhibit_slugs_ssim", "full_title_tesim", "spotlight_upload_description_tesim", "thumbnail_url_ssm", "exhibit_#{exhibit_id}_location_ssim"],
  :fq=> "exhibit_#{exhibit_id}_location_ssim:[* TO *]",
  :wt=> "ruby"
}

items = []
# only return items that have a valid lat/long in its location field
res['response']['docs'].each do |r|
 if r['exhibit_test-exhibit_location_ssim'].first.match(/(-?\d{1,3}\.\d+)/) != nil
   items.push(r)
 end
end

puts items
