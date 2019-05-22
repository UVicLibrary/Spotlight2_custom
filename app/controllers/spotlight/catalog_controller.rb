require 'byebug'
module Spotlight
  ##
  # Spotlight's catalog controller. Note that this subclasses
  # the host application's CatalogController to get its configuration,
  # partial overrides, etc
  # rubocop:disable Metrics/ClassLength
  class CatalogController < ::CatalogController
    include Spotlight::Concerns::ApplicationController
    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit, prepend: true
    include Spotlight::Catalog
    include Spotlight::Concerns::CatalogSearchContext

    before_action :authenticate_user!, only: [:admin, :edit, :make_public, :make_private]
    before_action :check_authorization, only: [:admin, :edit, :make_public, :make_private]
    before_action :redirect_to_exhibit_home_without_search_params!, only: :index

    before_action :attach_breadcrumbs
    before_action :add_breadcrumb_with_search_params, only: :index

    before_action only: :show do
      blacklight_config.show.partials.unshift 'tophat'
      blacklight_config.show.partials.unshift 'curation_mode_toggle'
    end

    before_action only: :admin do
      blacklight_config.view.select! { |k, _v| k == :admin_table }
      blacklight_config.view.admin_table.partials = [:index_compact]
      blacklight_config.view.admin_table.document_actions = []

      unless blacklight_config.sort_fields.key? :timestamp
        blacklight_config.add_sort_field :timestamp, sort: "#{blacklight_config.index.timestamp_field} desc"
      end
    end

    attr_reader :resource


    before_action only: :edit do
      blacklight_config.view.edit.partials = blacklight_config.view_config(:show).partials.dup
      blacklight_config.view.edit.partials.insert(2, :edit)

      @resource = Spotlight::Resource.find(params[:id].split("-").last)
    end

    before_action only: [:video, :manifest] do
      #solr_document_params
      setup_next_and_previous_documents
    end

    def destroy

    end

    def show

      super

      if @document.private? current_exhibit
        authenticate_user! && authorize!(:curate, current_exhibit)
      end

      add_document_breadcrumbs(@document)

      @resource = Spotlight::Resource.find(@document.id.split("-").last)
    end

    # "id_ng" and "full_title_ng" should be defined in the Solr core's schema.xml.
    # It's expected that these fields will be set up to have  EdgeNGram filter
    # setup within their index analyzer. This will ensure that this method returns
    # results when a partial match is passed in the "q" parameter.
    def autocomplete
      search_params = params.merge(search_field: Spotlight::Engine.config.autocomplete_search_field)
      (_, @document_list) = search_results(search_params.merge(public: true, rows: 100))

      respond_to do |format|
        format.json do
          render json: { docs: autocomplete_json_response(@document_list) }
        end
      end
    end

    def admin
      add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
      add_breadcrumb t(:'spotlight.curation.sidebar.items'), admin_exhibit_catalog_path(@exhibit)
      (@response, @document_list) = search_results(params)
      @filters = params[:f] || []

      respond_to do |format|
        format.html
      end
    end

    def update
      @response, @document = fetch params[:id]
      @document.update(current_exhibit, solr_document_params)
      @document.save

      try_solr_commit!

      redirect_to polymorphic_path([current_exhibit, @document])
    end

    def edit
      @response, @document = fetch params[:id]
    end

    def make_private
      @response, @document = fetch params[:id]
      @document.make_private!(current_exhibit)
      @document.save

      respond_to do |format|
        format.html { redirect_back(fallback_location: [spotlight, current_exhibit, @document]) }
        format.json { render json: true }
      end
    end

    def make_public
      @response, @document = fetch params[:id]
      @document.make_public!(current_exhibit)
      @document.save

      respond_to do |format|
        format.html { redirect_back(fallback_location: [spotlight, current_exhibit, @document]) }
        format.json { render json: true }
      end
    end

    # Searches for individual items to be combined into a manifest/compound object.
    # Returns a list of items with titles, option to add.
    def search

    end

    # Render a manifest as a raw json file
    # Order of operations: Spotlight's pre-generated manifest -> modified manifest (catalog#manifest)
    # -> manifest_fullscreen -> Mirador partial (renders modified manifest).
    # Catalog#show calls openseadragon_default view, which has an iframe to manifest_fullscreen.
    # See http://projectmirador.org/docs/docs/getting-started.html#iframe
    def manifest
      _, @document = fetch params[:id]
      @resource = Spotlight::Resource.find(params[:id].split("-").last)

      if @resource.file_type == "image"
        source_m = Spotlight::IiifManifestPresenter.new(@document, self).iiif_manifest_json
        source_m = IIIF::Service.parse(JSON.parse(source_m))
        canvas = source_m.sequences.first.canvases.first
        resource = canvas.images.first.resource
        results = dimensions_to_i(canvas, resource)
        canvas = results[0]
        resource = results[1]
        # source_m.metadata = [{'label'=>'Author', 'value'=>'Anne Author'}, {'label' => 'Date', 'value' => '1924'}]
        source_m.metadata = add_metadata
        manifest = source_m.to_json(pretty:true)
      else # If compound object, render the saved file
        doc_ids = @resource.compound_ids
        @resource_title = @resource.data["full_title_tesim"]
        @first_resource =  Spotlight::Resource.find(doc_ids.first.split("-").last)
        # Grab title from the first item in the compound object
        first_resource_title = @first_resource.data["full_title_tesim"]
        if @resource_title.blank?
          @resource_title = first_resource_title
        end
        seed = {
            '@id' => 'http://ophelia.library.uvic.ca/spotlight/test-exhibit/manifest',
            'label' => @resource_title
        }
        # Any options you add are added to the object
        manifest = IIIF::Presentation::Manifest.new(seed)
        # Create sequence headers
        sequence = IIIF::Presentation::Sequence.new(
          '@id'=> 'http://ophelia.library.uvic.ca/spotlight/test-exhibit/catalog/manifest',
          '@type' => 'sc:Sequence'
          )
        # Make canvases and add them to the sequence
        sequence.canvases = make_canvases(doc_ids)
        manifest.sequences << sequence
        manifest = manifest.to_json(pretty: true)
      end
      render json: manifest
    end

    # Uses manifest (generated by catalog#manfest) & renders fullscreen Mirador viewer for image or compound object
    def mirador_fullscreen
      _, @document = fetch params[:id]
      @resource = Spotlight::Resource.find(params[:id].split("-").last)
      respond_to do |format|
        format.html {render layout: false } # Don't render masthead or other stuff
      end
    end

    protected

    # Returns manifest heights and widths as integers so that manifest will validate
    def dimensions_to_i(canvas, resource)
      canvas.width = canvas.width.to_i
      canvas.height = canvas.height.to_i
      resource.width = resource.width.to_i
      resource.height = resource.height.to_i
      resource["@id"] = canvas["@id"]
      return [canvas, resource]
    end

    def add_metadata
      exhibit_slug = current_exhibit.slug
      # Get rid of labels that aren't metadata fields
      fields = []
      uploaded_resource_params[0][:configured_fields].each { |f| fields.push(f.to_s) }
      metadata = []
      all_upload_fields = Spotlight::Resources::Upload.fields(current_exhibit)
      # For every metadata field in the item, find the corresponding label
      fields.each do |field|
        if @document.keys.include? field
          value = @document[field][0]
          label = all_upload_fields.detect { |uf| uf.field_name.to_s == field }.label
          metadata.push({'label' => label, 'value' => value})
        end
      end
      return metadata
    end

    # Makes canvases for subsequent images in a compound object. Returns an array of canvas objects.
    def make_canvases(ids_array)
      new_array = []
      ids_array.each do |doc_id|
        _,document = fetch doc_id
        # .iiif_manifest_json was in the Spotlight gem version of the catalog#manifest action.
        # It takes a SolrDocument and returns a .json version of the manifest containing 1 image/canvas.
        source_m = Spotlight::IiifManifestPresenter.new(document, self).iiif_manifest_json
        source_m = IIIF::Service.parse(JSON.parse(source_m))
        canvas = source_m.sequences.first.canvases.first
        resource = canvas.images.first.resource
        # Label each canvas with the manifest label if there is one
        canvas.label = source_m.label if source_m.label
        # Change widths and heights to integers so manifest will be valid
        results = dimensions_to_i(canvas, resource)
        canvas = results[0]
        resource = results[1]
        new_array.push(canvas)
      end
      new_array.each do |canvas|
        if canvas.label.nil?
          assigned_label = (new_array.index(canvas) + 1).to_s
          canvas.label = assigned_label
        end
      end
      return new_array
    end

    # TODO: move this out of app/helpers/blacklight/catalog_helper_behavior.rb and into blacklight/catalog.rb
    # rubocop:disable Naming/PredicateName
    def has_search_parameters?
      !params[:q].blank? || !params[:f].blank? || !params[:search_field].blank?
    end
    # rubocop:enable Naming/PredicateName

    def attach_breadcrumbs
      # The "q: ''" is necessary so that the breadcrumb builder recognizes that a path like this:
      # /exhibits/1?f%5Bgenre_sim%5D%5B%5D=map&q= is not the same as /exhibits/1
      # Otherwise the exhibit breadcrumb won't be a link.
      # see http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-current_page-3F
      if view_context.current_page?(action: :admin)
        add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), exhibit_root_path(@exhibit, q: '')
      else
        # When not on the admin page, get the translated value for the "Home" breadcrumb
        add_breadcrumb t(:'spotlight.curation.nav.home', title: @exhibit.title), exhibit_root_path(@exhibit, q: '')
      end
    end

    ##
    # Override Blacklight's #setup_next_and_previous_documents to handle
    # browse categories too
    def setup_next_and_previous_documents
      if current_search_session_from_browse_category?
        setup_next_and_previous_documents_from_browse_category if current_browse_category
      elsif current_search_session_from_page? || current_search_session_from_home_page?
        # TODO: figure out how to construct previous/next documents
      else
        super
      end
    end

    def setup_next_and_previous_documents_from_browse_category
      index = search_session['counter'].to_i - 1
      response, documents = get_previous_and_next_documents_for_search index, current_browse_category.query_params.with_indifferent_access

      return unless response

      search_session['total'] = response.total
      @previous_document = documents.first
      @next_document = documents.last
    end

    def _prefixes
      @_prefixes ||= super + ['catalog']
    end

    ##
    # Admin catalog controller should not create a new search
    # session in the blacklight context
    def start_new_search_session?
      super || params[:action] == 'admin'
    end

    def solr_document_params
      params.require(:solr_document).permit(:exhibit_tag_list,
                                            uploaded_resource: [:url],
                                            sidecar: [:public, data: [editable_solr_document_params]])
    end

    def editable_solr_document_params
      custom_field_params + uploaded_resource_params
    end

    def uploaded_resource_params
      if @document.uploaded_resource?
        [{ configured_fields: Spotlight::Resources::Upload.fields(current_exhibit).map(&:field_name) }]
      else
        []
      end
    end

    def custom_field_params
      current_exhibit.custom_fields.writeable.pluck(:field)
    end

    def check_authorization
      authorize! :curate, @exhibit
    end

    def redirect_to_exhibit_home_without_search_params!
      redirect_to spotlight.exhibit_root_path(@exhibit) unless has_search_parameters?
    end

    def add_breadcrumb_with_search_params
      add_breadcrumb t(:'spotlight.catalog.breadcrumb.index'), spotlight.search_exhibit_catalog_path(params.to_unsafe_h) if has_search_parameters?
    end

    # rubocop:disable Metrics/AbcSize
    def add_document_breadcrumbs(document)
      if current_browse_category
        add_breadcrumb current_browse_category.exhibit.main_navigations.browse.label_or_default, exhibit_browse_index_path(current_browse_category.exhibit)
        add_breadcrumb current_browse_category.title, exhibit_browse_path(current_browse_category.exhibit, current_browse_category)
      elsif current_page_context && current_page_context.title.present? && !current_page_context.is_a?(Spotlight::HomePage)
        add_breadcrumb current_page_context.title, [current_page_context.exhibit, current_page_context]
      elsif current_search_session
        add_breadcrumb t(:'spotlight.catalog.breadcrumb.index'), search_action_url(current_search_session.query_params)
      end

      add_breadcrumb Array(document[blacklight_config.view_config(:show).title_field]).join(', '), polymorphic_path([current_exhibit, document])
    end
    # rubocop:enable Metrics/AbcSize

    def additional_export_formats(document, format)
      super

      format.solr_json do
        authorize! :update_solr, @exhibit
        render json: document.to_solr.merge(@exhibit.solr_data)
      end
    end

    def try_solr_commit!
      repository.connection.commit
    rescue => e
      Rails.logger.info "Failed to commit document updates: #{e}"
    end
  end
end
