require 'json'
require 'byebug'
require 'rest_client'
require "uri"
require "net/https"

module Spotlight
  module Resources
    ##
    # Creating new exhibit items from single-item entry forms
    # or batch CSV upload
    class UploadController < Spotlight::ApplicationController
      helper :all

      before_action :authenticate_user!

      load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
      before_action :build_resource

      load_and_authorize_resource class: 'Spotlight::Resources::Upload', through_association: 'exhibit.resources', instance_name: 'resource'

      attr_accessor :featured_image

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def create
        # Is compound object
        if params[:resources_upload][:compound_ids].present?
          @resource.compound_ids = params[:resources_upload][:compound_ids].first.delete(" \"").split(",")
        else
          @resource.file_name = set_file_name
        end
        @resource.attributes = resource_params
        # @resource.blarg
        if @resource.file_type != "image"
          # If we don't explicitly create a featured image, Solr won't index the file
          placeholder = Spotlight::FeaturedImage.create
        end
        # Line calling FeaturedImageUploader
        @resource.build_upload(image: params[:resources_upload][:url])

        if @resource.save_and_index
            # Upload to Sketchfab
            if @resource.file_type == "model"
              title = @resource.data["full_title_tesim"]
              description = @resource.data["spotlight_upload_description_tesim"]
              data = {
                  'name' => title,
                  'description' => description,
                  'isPublished' => "true",
                  'modelFile'=> File.new('public/uploads/spotlight/featured_image/image/' + @resource.upload.id.to_s + '/'+ @resource.file_name.to_s, 'rb')
              }
              # To Do: Replace with UVic account's API token
              response = RestClient.post("https://api.sketchfab.com/v3/models", data, {:Authorization => 'Token 18e737793f7747c28b86d3c139d42789', accept: :json})
              # Save Sketchfab uid to column in resource
              @resource.uid = JSON.parse(response.body)["uid"]
              @resource.save
            end

          # Save and re-index so it shows up in Solr & Items list
          @resource.reindex

          flash[:notice] = t('spotlight.resources.upload.success')
          if params['add-and-continue']
            redirect_to new_exhibit_resource_path(@resource.exhibit, anchor: :new_resources_upload)
          else
            redirect_to admin_exhibit_catalog_path(@resource.exhibit, sort: :timestamp)
          end
        else
          flash[:error] = t('spotlight.resources.upload.error')
          redirect_to admin_exhibit_catalog_path(@resource.exhibit, sort: :timestamp)
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize


      private

      def build_resource
        @resource ||= Spotlight::Resources::Upload.new exhibit: current_exhibit
      end

      def set_file_name
        upload_params = params.require(:resources_upload).permit(:url)
        params[:resources_upload][:url].original_filename
      end

      def resource_params
        params.require(:resources_upload).permit(data: data_param_keys)
      end

      def compound_object_params
        params.require(:resources_upload).permit(:compound_ids)
      end

      def data_param_keys
        Spotlight::Resources::Upload.fields(current_exhibit).map(&:field_name) + current_exhibit.custom_fields.map(&:field)
      end
    end
  end
end
