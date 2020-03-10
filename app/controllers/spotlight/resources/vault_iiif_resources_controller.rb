module Spotlight
  module Resources
    # IIIF resources harvesting endpoint
    class VaultIiifResourcesController < Spotlight::ResourcesController

      def create
        
        if @resource.url.present?
          manifest = @resource.iiif_manifests.first
          manifest.with_exhibit(@resource.exhibit)
          manifest.with_resource(@resource)
          @resource.data = manifest.manifest_metadata
          @resource.file_name = "default.jpg" # needed for calculating resource.file_type
        end

        super

      end

    end
  end
end
