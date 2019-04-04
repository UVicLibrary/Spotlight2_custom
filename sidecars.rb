src_lines = File.readlines('spotlight21.sql')

# Open a new file to print results
File.open("spotlight21-new.sql", "w") do |f|
  #Open taggings table
  src_lines.each do |tagging|
    if tagging_match = tagging.match(/^\(\d+\,\d+,('.*?')/)
      if tagging.include? "SolrDocument"
        tagging.gsub!("SolrDocument", "Spotlight::SolrDocumentSidecar")
        doc_id = tagging_match.captures.first
        # Open sidecars table
        sidecar_lines = File.readlines('spotlight20.sql')
          sidecar_lines.each do |sidecar|
            # Find the sidecar from matching document ID
            if sidecar_match = sidecar.match(/#{doc_id},'Solr/)
              # Get ID of sidecar
              sidecar_id = sidecar.match(/^\((\d+)/).captures.first
              # Replace the doc_id in taggings with the sidecar_id
              tagging.gsub!(doc_id, sidecar_id)
              f.puts tagging
            end
          end # Sidecar_lines.each do
      else # If tag is on exhibit
        exhibit_id_string = tagging_match.captures.first
        #puts tagging.gsub!(exhibit_id_string, exhibit_id_string.gsub("'",""))
        f.puts tagging.gsub!(exhibit_id_string, exhibit_id_string.gsub("'",""))
      end # tagging.include? "SolrDocument"
    else
      f.puts tagging
    end # if tagging_match
  end # src_lines
end # Open insert results
