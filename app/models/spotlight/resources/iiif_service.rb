# frozen_string_literal: true

require 'iiif/presentation'
module Spotlight
  module Resources
    ###
    # Wrapper around IIIF-Presentation's IIIF::Service that provides the
    # ability to recursively traverse through all collections and manifests
    class IiifService
      def initialize(url)
        @url = url
      end

      def collections
        @collections ||= (object.try(:collections) || []).map do |collection|
          self.class.new(collection['@id'])
        end
      end

      def manifests
        @manifests ||= if manifest? && @url.include?("vault.library.uvic.ca")
                         [create_vault_iiif_manifest(object)]
                       elsif manifest?
                         [create_iiif_manifest(object)]
                       else
                         build_collection_manifest.to_a
                       end
      end

      def self.parse(url)
        recursive_manifests(new(url))
      end

      # protected

      def object
        @object ||= IIIF::Service.parse(response)
      end

      # private

      attr_reader :url

      class << self
        def iiif_response(url)
          #byebug
          begin
          if url.include?("vault.library.uvic.ca")
            conn = Faraday.new(url, { ssl: {verify:false}})
            conn.get.body
          else
            Faraday.get(url).body
          end
            rescue Faraday::Error::ConnectionFailed, Faraday::TimeoutError => e
            Rails.logger.warn("HTTP GET for #{url} failed with #{e}")
            {}.to_json
          end
        end


        private

        def recursive_manifests(thing, &block)
          return to_enum(:recursive_manifests, thing) unless block_given?

          thing.manifests.each(&block)

          return unless thing.collections.present?

          thing.collections.each do |collection|
            recursive_manifests(collection, &block)
          end
        end
      end

      def create_iiif_manifest(manifest, collection = nil)
        IiifManifest.new(url: manifest['@id'], manifest: manifest, collection: collection)
      end

      def create_vault_iiif_manifest(manifest, collection = nil)
        Spotlight::Resources::VaultIiifManifest.new(url: manifest['@id'], manifest: manifest, collection: collection)
      end

      def manifest?
        object.is_a?(IIIF::Presentation::Manifest)
      end

      def collection?
        object.is_a?(IIIF::Presentation::Collection)
      end

      def response
        @response ||= self.class.iiif_response(url)
      end

      def build_collection_manifest
        return to_enum(:build_collection_manifest) unless block_given?

        if collection? && @url.include?("vault.library.uvic.ca")
          self_manifest = create_vault_iiif_manifest(object)
        elsif collection?
          self_manifest = create_iiif_manifest(object)
        end
        yield self_manifest

        (object.try(:manifests) || []).each do |manifest|
          yield create_vault_iiif_manifest(self.class.new(manifest['@id']).object, self_manifest)
          # yield create_iiif_manifest(self.class.new(manifest['@id']).object, self_manifest)
        end
      end
    end
  end
end
