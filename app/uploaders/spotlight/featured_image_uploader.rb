module Spotlight

  # Page, browse category, and exhibit featured image thumbnails
  class FeaturedImageUploader < CarrierWave::Uploader::Base

    # Requirements for making thumbnails from videos
    include CarrierWave::RMagick
    include VideoThumbnailer

    storage Spotlight::Engine.config.uploader_storage

    def extension_whitelist
      Spotlight::Engine.config.allowed_upload_extensions
    end

    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end

    def png_name for_file, version_name, format
      %Q{#{version_name}_#{for_file.chomp(File.extname(for_file))}.#{format}}
    end

    version :thumb, if: :is_video?

    version :thumb do
        process generate_thumb:[{:size => "400x400",:quality => 5, :time_frame => "00:0:06", :file_extension => "jpeg" }]
        def full_filename for_file
          png_name for_file, version_name, "jpeg"
        end
    end

    def is_video?(file)
      file.content_type.include?("video")# || file.content_type.include?("ogg")
    end

  end
end
