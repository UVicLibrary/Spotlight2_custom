module Spotlight
  # Used by RIIIF to find files uploaded by carrierwave
  class CarrierwaveFileResolver < Riiif::AbstractFileSystemResolver    # Override initialzer to avoid deprecation about not providing base path
    def initializer
      # nop
    end

    def pattern(id)
      # if resource.file_type = "video"
      #   uploaded_file = File.join(Rails.root, 'app/assets/images/placeholder.jpg').file
      #   uploaded_file.file
      #
      # else
        uploaded_file = Spotlight::FeaturedImage.find(id).image.file
        raise Riiif::ImageNotFoundError, "unable to find file for #{id}" if uploaded_file.nil?
        uploaded_file.file
      # end

    end
  end
end
