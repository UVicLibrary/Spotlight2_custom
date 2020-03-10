# frozen_string_literal: true

require 'iiif/presentation'

module Spotlight
  module Resources
    # harvest Images from IIIF Manifest and turn them into a Spotlight::Resource
    # Note: IIIF API : http://iiif.io/api/presentation/2.0
    class IiifHarvester < Spotlight::Resource
      self.document_builder_class = Spotlight::Resources::IiifBuilder
      self.weight = -5000

      validate :valid_url?

      def iiif_manifests
        @iiif_manifests ||= IiifService.parse(url)
      end

      # id of the associated document
      def compound_id
        "#{self.exhibit_id}-#{self.id}"
      end

      # Build and index the solr document
      def build_resource_and_document
        manifest = @resource.iiif_manifests.first # See /models/spotlight/resources/vault_iiif_manifest.rb
        manifest.with_exhibit(@resource.exhibit)
        manifest.with_resource(@resource)
        @resource.data = manifest.manifest_metadata.transform_values { |v| v.first } # We want to index the SolrDocument with a multiple value ({ k => ['v'] }
      end

      private

      def valid_url?
        errors.add(:url, 'Invalid IIIF URL') unless url_is_iiif?(url)
      end

      def url_is_iiif?(url)
        valid_content_types = ['application/json', 'application/ld+json']
        if url.include?("vault.library.uvic.ca") # Trust Vault only
          conn = Faraday.new(url, { ssl: {verify:false}})
          req = conn.get
        else
          req = Faraday.head(url)
          req = Faraday.get(url) if req.status == 405
          return unless req.success?
        end

        valid_content_types.any? do |valid_type|
          req.headers['content-type'].include?(valid_type)
        end

      end
    end
  end
end
