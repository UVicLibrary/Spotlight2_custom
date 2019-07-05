module Spotlight
  # Requirements for making thumbnails from videos
  include CarrierWave::RMagick
  include VideoThumbnailer
  # require 'rmagick'
  # For making PDF thumbnails
  require 'combine_pdf'
  require 'pdftoimage'
  require 'fileutils'

  # Creates solr documents for the uploaded documents in a resource
  class UploadSolrDocumentBuilder < SolrDocumentBuilder
    delegate :compound_id, to: :resource

    # Find the first resource in the compound_ids (attribute)
    def first_resource(compound_object)
      Spotlight::Resource.find(compound_object.compound_ids.first.split("-")[1])
    end

    def to_solr

      file_types_list = ["image", "video", "compound_object", "pdf"]

      super.tap do |solr_hash|
          add_default_solr_fields solr_hash
          add_manifest_path solr_hash
          add_sidecar_fields solr_hash
        if file_types_list.include?(resource.file_type) or (first_resource(resource).file_type == "image" if resource.file_type == "compound object")
            add_file_versions solr_hash
          if resource.file_type == "image" or (first_resource(resource).file_type == "image" if resource.file_type == "compound object")
            add_image_dimensions solr_hash
          end
        end
      end
    end

    private

    def add_default_solr_fields(solr_hash)
      solr_hash[exhibit.blacklight_config.document_model.unique_key.to_sym] = compound_id
    end

    def add_image_dimensions(solr_hash)
      # To Do: if resource is video, use video thumbnail
      if resource.file_type == "image"
        dimensions = Riiif::Image.new(resource.upload_id).info
      else # is compound object
        dimensions = Riiif::Image.new(first_resource(resource).upload_id).info
      end
      solr_hash[:spotlight_full_image_width_ssm] = dimensions.width
      solr_hash[:spotlight_full_image_height_ssm] = dimensions.height
    end

    # Creates thumbnails for different types of resources and adds the link to thumbnail_url_ssm in solr hash
    def add_file_versions(solr_hash)
      file_path = "public/uploads/spotlight/featured_image/image/#{resource.upload_id}/#{resource.file_name}"
      if resource.file_type == "image"
        solr_hash[Spotlight::Engine.config.thumbnail_field] = riiif.image_path(resource.upload_id, size: '!400,400')
      elsif resource.file_type == "compound object"
        solr_hash[Spotlight::Engine.config.thumbnail_field] = riiif.image_path(first_resource(resource).upload_id, size: '!400,400')
      elsif resource.file_type == "pdf"
        first_page = CombinePDF.load(file_path).pages[0]
        pdf_name = resource.file_name.split(".").first
        new_pdf = CombinePDF.new
        new_pdf << first_page
        dirname = File.dirname(file_path)
        first_page_path = "#{dirname}/#{pdf_name}-cover.pdf"
        new_pdf.save first_page_path
        image = PDFToImage.open(first_page_path).first.resize("50%").save("#{dirname}/#{pdf_name}-thumb.jpeg")
        # File.delete(first_page_path)
        solr_hash[Spotlight::Engine.config.thumbnail_field] = "#{file_path.sub!("public","").sub!("#{resource.file_name}","/#{pdf_name}-thumb.jpeg")}"
      else # if resource.file_type = "video"
        # Generate thumbnail unless it already has one
        files = Dir.entries(file_path)
        unless files.any? { |f| f.include? "jpeg" }
          # See uploaders/featured_image_uploader.rb
          featured_image = resource.upload
          featured_image.image.recreate_versions!
        end
      end
    end

    # Send the document data to be indexed by solr
    def add_sidecar_fields(solr_hash)
      solr_hash.merge! resource.sidecar.to_solr
    end

    def add_manifest_path(solr_hash)
      solr_hash[Spotlight::Engine.config.iiif_manifest_field] = spotlight_routes.manifest_exhibit_solr_document_path(exhibit, resource.compound_id)
    end

    def spotlight_routes
      Spotlight::Engine.routes.url_helpers
    end

    def riiif
      Riiif::Engine.routes.url_helpers
    end

  end
end
