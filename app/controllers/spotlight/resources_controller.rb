module Spotlight
  ##
  # CRUD actions for exhibit resources
  class ResourcesController < Spotlight::ApplicationController

    require 'byebug'

    before_action :authenticate_user!, except: [:show]

    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit

    # explicit options support better subclassing
    load_and_authorize_resource through: :exhibit, instance_name: :resource, through_association: :resources

    helper_method :resource_class

    def new
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), exhibit_root_path(@exhibit)
      add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
      add_breadcrumb t(:'spotlight.curation.sidebar.items'), admin_exhibit_catalog_path(@exhibit)
      add_breadcrumb t(:'spotlight.resources.new.header'), new_exhibit_resource_path(@exhibit)

      render
    end

    def create
      if @resource.save_and_index
        redirect_to spotlight.admin_exhibit_catalog_path(@resource.exhibit, sort: :timestamp)
      else
        flash[:error] = @resource.errors.full_messages.to_sentence if @resource.errors.present?
        render action: 'new'
      end
    end
    alias update create

    def show

    end

    def destroy
      @resource = Spotlight::Resource.find(params[:id])
      @exhibit = @resource.exhibit
      delete_document
      @resource.destroy
      flash[:notice] = "Item was successfully deleted"
      redirect_to admin_exhibit_catalog_path(@exhibit)
    end

    def delete_document
      solr = RSolr.connect :url => 'http://localhost:8983/solr/blacklight-core'
      doc_id = @resource.compound_id
      solr.delete_by_id doc_id
      solr.commit
    end

    def get_solr
      # items = []
      solr = RSolr.connect :url => 'http://localhost:8983/solr/blacklight-core'
      solr.get 'select', :params => {
        :q => params[:q],
        :start => 0,
        :rows => 20,
        :fl => ["id", "full_title_tesim", "spotlight_upload_description_tesim", "thumbnail_url_ssm"],
        :fq => ["exhibit_#{@exhibit.slug}_public_bsi:true"],
        :wt => "ruby"
      }
    end

    def index
      # Search for documents on new_manifest page
      if params[:q]
        response = get_solr
        @num_results = response['response']['numFound']
        @results = response['response']['docs']
        # Filter out results that aren't images
        # @results.reject! { |r| r['thumbnail_url_ssm'].nil? }
        @results.each do |r|
          resource_id = r["id"].split("-")[1]
          resource = Spotlight::Resource.find(resource_id)
          if resource.file_type != "image"
            @results.delete(r)
          end
        end

        respond_to do |format|
          format.js {
            render partial: 'results'
          }
        end
      end
    end

    def monitor
      render json: current_exhibit.reindex_progress
    end

    def new_manifest
      @resource = Spotlight::Resources::Upload.new()
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), exhibit_root_path(@exhibit)
      add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
      add_breadcrumb t(:'spotlight.curation.sidebar.items'), admin_exhibit_catalog_path(@exhibit)
      add_breadcrumb "Add compound object", request.original_url
    end

    def google_map
      # Direct connection
      solr = RSolr.connect :url => 'http://localhost:8983/solr/blacklight-core'

      # Spotlight needs the exhibit ID to find custom metadata fields (location is no longer a default metadata field)
      exhibit_id = "test-exhibit"

      query = "" #self.search.nil? ? "*:*" : self.search.gsub(',',' OR ')
      res = solr.get 'select', :params => {
        :q=>query,
        :start=>0,
        :rows=>1000,
        :fl=> ["id", "spotlight_exhibit_slugs_ssim", "full_title_tesim", "spotlight_upload_description_tesim", "thumbnail_url_ssm", "exhibit_#{exhibit_id}_location_ssim"],
        :fq=> "exhibit_#{exhibit_id}_location_ssim:[* TO *]",
        :wt=> "ruby"
      }

      @items = []
      # only return items that have a valid lat/long in its location field
      res['response']['docs'].each do |r|
       if r['exhibit_test-exhibit_location_ssim'].first.match(/(-?\d{1,3}\.\d+)/) != nil
         @items.push(r)
       end
      end
      @items.sort!{|a,b| a['full_title_tesim'][0].downcase <=> b['full_title_tesim'][0].downcase}
      # render json: @items.to_json

    end

    def reindex_all
      @exhibit.reindex_later current_user

      redirect_to admin_exhibit_catalog_path(@exhibit), notice: t(:'spotlight.resources.reindexing_in_progress')
    end

    protected

    def resource_class
      Spotlight::Resource
    end

    def resource_params
      params.require(:resource).tap { |x| x['type'] ||= resource_class.name }
            .permit(:url, :type, :q, *resource_class.stored_attributes[:data], data: params[:resource][:data].try(:keys))
    end
  end
end
