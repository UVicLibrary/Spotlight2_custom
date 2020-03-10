module Spotlight
  module Resources
    ##
    class VaultIiifManifest < Spotlight::Resources::IiifManifest

      def to_solr
        add_document_id
        add_label
        add_full_image_urls
        add_thumbnail_url
        add_manifest_url
        add_image_urls
        add_metadata
        add_image_dimensions
        add_collection_id
        solr_hash
      end

      def manifest_metadata
        metadata = metadata_class.new(manifest).to_solr # Returns a hash with metadata that gets sent to solr { k => ['val'] }
        return {} unless metadata.present?
        if @resource.data.blank? # Checks if resource was imported via CSV or URL. If from CSV, resource will already have something in the data field
            configured_fields = Spotlight::Resources::Upload.fields(exhibit)
            # Add rights_statement => Rights; and provider => Contributor since they are mandatory in Vault
            metadata_hash = { "spotlight_upload_Rights_tesim" => (metadata["Rights statement"]), "spotlight_upload_Contributors_tesim" => (metadata["Provider"]) }
            labels = configured_fields.map(&:label)
            matching_labels = metadata.keys & labels
            if matching_labels.present?
              # If there is something in Vault's contributor field, append it to Spotlight's contributor field
               if matching_labels.include?("Contributor")
                 matching_labels.delete("Contributor")
                 metadata_hash["spotlight_upload_Contributors_tesim"] = ["#{metadata['Provider'].first + '; ' + metadata['Contributor']}"]
               end
              # Match spotlight metadata fields to Vault fields using their labels as a matchpoint.
              matching_labels.each_with_object(metadata_hash) do |label, hash|
                matching_field = configured_fields.find { |f| f.label == label }
                hash[matching_field.field_name] = metadata[label]
              end
            end
        else
          @resource.data
        end

      end

      def with_resource(r)
        @resource = r
      end

      def compound_id
        "#{exhibit.id}-#{@resource.id}"
      end

      def add_thumbnail_url
        return unless thumbnail_field
        # Use the IIIF image API to grab a thumbnail URL if the manifest doesn't specify a thumbnail
        if manifest['thumbnail'].present?
          solr_hash[thumbnail_field] = manifest['thumbnail']['@id']
        else
          solr_hash[thumbnail_field] = full_image_url.gsub('600,','!400,400')
        end
      end

      def add_metadata
        solr_hash.merge!(manifest_metadata)
        # We want to index the SolrDocument with a multiple value ({ k => ['v'] }
        # but Resource.data should index the string value, data: { k => 'v' }
        if @resource.data.present?
          sidecar.update(data: {"configured_fields" => @resource.data})
        else
          sidecar.update(data: {"configured_fields" => sidecar.data.merge(manifest_metadata.transform_values { |v| v.first }) })
        end
      end

      def add_image_dimensions
        solr_hash['spotlight_full_image_height_ssm'] = [self.resources.first.height.to_s]
        solr_hash['spotlight_full_image_width_ssm'] = [self.resources.first.width.to_s]
      end

      end
    end
  end
