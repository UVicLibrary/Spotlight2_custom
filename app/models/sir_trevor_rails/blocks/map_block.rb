module SirTrevorRails
  module Blocks

    class MapBlock < SirTrevorRails::Block

      #get items from solr to display on the map block
      #search value is from block
      def getsolr
        items = Array.new
        solr = RSolr.connect :url => 'http://localhost:8983/solr/blacklight-core'

        # Spotlight needs the exhibit ID to find custom metadata fields (location is no longer a default metadata field)
        exhibit_id = "test-exhibit"

        query = self.search.nil? ? "*:*" : self.search.gsub(',',' OR ')
        res = solr.get 'select', :params => {
          :q=>query,
          :start=>0,
          :rows=>1000,
          :fl=> ["id", "spotlight_exhibit_slugs_ssim", "full_title_tesim", "spotlight_upload_description_tesim", "thumbnail_url_ssm", "exhibit_#{exhibit_id}_location_ssim"],
          :fq=> "exhibit_#{exhibit_id}_location_ssim:[* TO *]",
          :wt=> "ruby"
        }

        #only return items that have a valid lat/long in its location field
        res['response']['docs'].each do |r|
          if r["exhibit_#{exhibit_id}_location_ssim"][0].match(/(-?\d{1,3}\.\d+)/) != nil
            items.push(r)
          end
        end
        #sort items by title
        items.sort!{|a,b| a['full_title_tesim'][0].downcase <=> b['full_title_tesim'][0].downcase}
      end


    end
  end
end
