##
# Simplified catalog controller
class CatalogController < ApplicationController
  include Blacklight::Catalog

  configure_blacklight do |config|
          config.show.oembed_field = :oembed_url_ssm
          config.show.partials.insert(1, :oembed)

    config.view.gallery.partials = [:index_header, :index]
    config.view.masonry.partials = [:index]
    config.view.slideshow.partials = [:index]

    # if @resource.data['full_title_tesim'].present?
      # solr field configuration for search results/index views
    config.index.title_field = 'full_title_tesim'
    # end

    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: 'search',
      rows: 10,
      fl: '*'
    }

    config.document_solr_path = 'get'
    config.document_unique_id_param = 'ids'

    # Configure facet fields
    #config.add_facet_field 'spotlight_upload_dc_Subjects_ftesim', label: "Subject(s)", limit: true
    #config.add_facet_field 'spotlight_upload_dc_Date-Created_Searchable_ftesi', label: 'Date', limit: true
    #config.add_facet_field 'spotlight_upload_dc_Type_Genre_ftesim', label: 'Genre', limit: true
    #config.add_facet_field 'spotlight_upload_Language_ftesim', label: 'Language', limit: true
    #config.add_facet_field "spotlight_upload_dc_Coverage-Spatial_Location_ftesim", label: 'Location(s)', limit: true
    #config.add_facet_field "spotlight_upload_dc_Subject_People_ftesim", label: 'People', limit: true
    #config.add_facet_field "spotlight_upload_dc_Relation_IsPartOf_Collection_ftesim", label: 'Collection', limit: true
    #config.add_facet_field "spotlight_upload_Format_tesim", label: 'Format', limit: true

          config.add_facet_field "full_title_tesim", label: 'Title'

          config.add_facet_field "spotlight_upload_attribution_tesim", label: 'Attribution'

    config.add_field_configuration_to_solr_request!
    config.add_facet_fields_to_solr_request!

    config.add_search_field 'all_fields', label: I18n.t('spotlight.search.fields.search.all_fields')

    config.add_sort_field 'relevance', sort: 'score desc', label: I18n.t('spotlight.search.fields.sort.relevance')

    config.add_field_configuration_to_solr_request!

    # Set which views by default only have the title displayed, e.g.,
    # config.view.gallery.title_only_by_default = true


  end
end
