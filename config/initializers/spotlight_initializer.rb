# ==> User model
# Note that your chosen model must include Spotlight::User mixin
# Spotlight::Engine.config.user_class = '::User'

# ==> Blacklight configuration
# Spotlight uses this upstream configuration to populate settings for the curator
# Spotlight::Engine.config.catalog_controller_class = '::CatalogController'
# Spotlight::Engine.config.default_blacklight_config = nil

# ==> Appearance configuration
# Spotlight::Engine.config.exhibit_main_navigation = [:curated_features, :browse, :about]
# Spotlight::Engine.config.resource_partials = [
#   'spotlight/resources/external_resources_form',
#   'spotlight/resources/upload/form',
#   'spotlight/resources/csv_upload/form',
#   'spotlight/resources/json_upload/form'
# ]
# Spotlight::Engine.config.external_resources_partials = []
# Spotlight::Engine.config.default_browse_index_view_type = :gallery
# Spotlight::Engine.config.default_contact_email = nil

# ==> Solr configuration
# Spotlight::Engine.config.writable_index = true
# Spotlight::Engine.config.solr_batch_size = 20
# Spotlight::Engine.config.filter_resources_by_exhibit = true
# Spotlight::Engine.config.autocomplete_search_field = 'autocomplete'
# Spotlight::Engine.config.default_autocomplete_params = { qf: 'id^1000 full_title_tesim^100 id_ng full_title_ng' }

# Solr field configurations
# Spotlight::Engine.config.solr_fields.prefix = ''.freeze
# Spotlight::Engine.config.solr_fields.boolean_suffix = '_bsi'.freeze
# Spotlight::Engine.config.solr_fields.string_suffix = '_ssim'.freeze
# Spotlight::Engine.config.solr_fields.text_suffix = '_tesim'.freeze
# Spotlight::Engine.config.resource_global_id_field = :"#{config.solr_fields.prefix}spotlight_resource_id#{config.solr_fields.string_suffix}"
# Spotlight::Engine.config.full_image_field = :full_image_url_ssm
# Spotlight::Engine.config.thumbnail_field = :thumbnail_url_ssm

# ==> Uploaded item configuration
Spotlight::Engine.config.upload_fields = [
#   UploadFieldConfig.new(
#     field_name: config.upload_description_field,
#     label: -> { I18n.t(:"spotlight.search.fields.#{config.upload_description_field}") },
#     form_field_type: :text_area
#   ),
#   UploadFieldConfig.new(
#     field_name: :spotlight_upload_attribution_tesim,
#     label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_attribution_tesim') }
#   ),
#   UploadFieldConfig.new(
#     field_name: :spotlight_upload_date_tesim,
#     label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_date_tesim') }
#   )
Spotlight::UploadFieldConfig.new(
  field_name: "spotlight_upload_dc_description_tesim",
  label: 'Description',
  form_field_type: :text_area),
Spotlight::UploadFieldConfig.new(
  field_name: "spotlight_upload_Contributors_tesim",
  label: 'Contributors'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_dc_Subject_tesim",
    label: 'Abstract',
    form_field_type: :text_area),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_dc_Subjects_tesim",
    label: 'Subjects',
    form_field_type: :text_area),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_dc_Subjects_ftesim",
    label: 'Subjects Facet',
    form_field_type: :text_area),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_Creator_tesim",
    label: 'Creator'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_Publisher_tesim",
    label: 'Publisher'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_Contributors_tesim",
    label: 'Contributors'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_dc_Date_tesi", #tesim to tesi
    label: 'Date',
    form_field_type: :text_area),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_dc_Date-Created_Searchable_ftesi", # ftesim to ftesi
    label: 'Date searchable',
    form_field_type: :text_area),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_dc_Date-Created_Searchable_tesi", # ftesim to ftesi
    label: 'Date searchable',
    form_field_type: :text_area),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_dc_Type_Genre_tesim",
    label: 'Genre',
    form_field_type: :text_area),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_dc_Type_Genre_ftesim",
    label: 'Genre Facet',
    form_field_type: :text_area),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_Format_tesim",
    label: 'Format'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_Identifier_tesim",
    label: 'Identifier'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_Source_tesim",
    label: 'Source'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_Language_tesim",
    label: 'Language'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_Language_ftesim",
    label: 'Language Facet'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_Relation_tesim",
    label: 'Relation'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_Coverage_tesim",
    label: 'Coverage'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_Rights_tesim",
    label: 'Rights'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_Provenance_tesim",
    label: 'Provenance'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_dc_Title_Alternative_tesim",
    label: 'Title-Alternative',
    form_field_type: :text_area),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_Description-Table-Of-Contents_tesim",
    label: 'Description-Table Of Contents'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_Description-Abstract_tesim",
    label: 'Description-Abstract'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_Format-Extent_tesim",
    label: 'Format-Extent'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_Format-Medium_tesim",
    label: 'Format-Medium'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_Identifier-Bibliographic-Citation_tesim",
    label: 'Identifier-Bibliographic Citation'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_dc_Relation_IsPartOf_Collection_tesim",
    label: 'Collection',
    form_field_type: :text_area),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_dc_Relation_IsPartOf_Collection_ftesim",
    label: 'Collection Facet',
    form_field_type: :text_area),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_dc_Coverage-Spatial_Location_tesim",
    label: 'Location(s)',
    form_field_type: :text_area),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_dc_Coverage-Spatial_Location_ftesim",
    label: 'Location(s) Facet',
    form_field_type: :text_area),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_Coverage-Temporal_tesim",
    label: 'Coverage-Temporal'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_Date-Digitized_tesi", #tesim to tesi
    label: 'Date Digitized'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_dc_Description_Transcript_tesim",
    label: 'Transcript',
    form_field_type: :text_area),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_dc_Subject_People_tesim",
    label: 'People Depicted',
    form_field_type: :text_area),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_dc_Subject_People_ftesim",
    label: 'People Facet',
    form_field_type: :text_area),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_Sketchfab-uid_tesim",
    label: 'Sketchfab Uid'),
Spotlight::UploadFieldConfig.new(
    field_name: :spotlight_annotation_x_dbsm,
    label: 'Hidden'),
Spotlight::UploadFieldConfig.new(
    field_name: :spotlight_annotation_y_dbsm,
    label: 'Hidden'),
Spotlight::UploadFieldConfig.new(
    field_name: :spotlight_annotation_width_dbsm,
    label: 'Hidden'),
Spotlight::UploadFieldConfig.new(
    field_name: :spotlight_annotation_height_dbsm,
    label: 'Hidden'),
Spotlight::UploadFieldConfig.new(
    field_name: :spotlight_annotation_title_tesim,
    label: 'Hidden'),
Spotlight::UploadFieldConfig.new(
    field_name: :spotlight_annotation_author_tesim,
    label: 'Hidden'),
Spotlight::UploadFieldConfig.new(
    field_name: :spotlight_annotation_description_tesim,
    label: 'Hidden'),
Spotlight::UploadFieldConfig.new(
    field_name: :spotlight_annotation_date_tesim,
    label: 'Hidden'),
Spotlight::UploadFieldConfig.new(
    field_name: :spotlight_annotation_publisher_tesim,
    label: 'Hidden'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_annotation_publisher-place_tesim",
    label: 'Hidden'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_annotation_publisher-date_tesim",
    label: 'Hidden'),
Spotlight::UploadFieldConfig.new(
    field_name: :spotlight_annotation_people_tesim,
    label: 'Hidden'),
Spotlight::UploadFieldConfig.new(
    field_name: :spotlight_annotation_locations_tesim,
    label: 'Hidden'),
Spotlight::UploadFieldConfig.new(
    field_name: :spotlight_annotation_transcript_tesim,
    label: 'Hidden'),
Spotlight::UploadFieldConfig.new(
    field_name: :spotlight_annotation_genre_tesim,
    label: 'Hidden'),
Spotlight::UploadFieldConfig.new(
    field_name: :spotlight_annotation_public_isim,
    label: 'Hidden'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_parent_tesim",
    label: 'Parent'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_Commentary_tesim",
    label: 'Commentary'), #'User Defined 1'
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_UserDefined_tesim",
    label: 'User Defined 2'),
Spotlight::UploadFieldConfig.new(
    field_name: "sortDate",
    label: 'sortDate'),
Spotlight::UploadFieldConfig.new(
    field_name: "spotlight_upload_dc_box_tesim",
    label: 'Geographic Coordinates')
]
# Spotlight::Engine.config.upload_title_field = nil # UploadFieldConfig.new(...)
# Spotlight::Engine.config.uploader_storage = :file
Spotlight::Engine.config.allowed_upload_extensions = %w(jpg jpeg png pdf mp4)

# Spotlight::Engine.config.featured_image_thumb_size = [400, 300]
# Spotlight::Engine.config.featured_image_square_size = [400, 400]

# ==> Google Analytics integration
# Spotlight::Engine.config.analytics_provider = nil
# Spotlight::Engine.config.ga_pkcs12_key_path = nil
# Spotlight::Engine.config.ga_web_property_id = nil
# Spotlight::Engine.config.ga_email = nil
# Spotlight::Engine.config.ga_analytics_options = {}
# Spotlight::Engine.config.ga_page_analytics_options = config.ga_analytics_options.merge(limit: 5)

# ==> Sir Trevor Widget Configuration
 Spotlight::Engine.config.sir_trevor_widgets = %w(
   Heading Text List Quote Iframe Video Oembed Rule UploadedItems Browse
   FeaturedPages SolrDocuments SolrDocumentsCarousel SolrDocumentsEmbed
   SolrDocumentsFeatures SolrDocumentsGrid SearchResults Map GoogleMap
 )
#
# Page configurations made available to widgets
# Spotlight::Engine.config.page_configurations = {
#   'my-local-config': ->(context) { context.my_custom_data_path(context.current_exhibit) }
# }
 Spotlight::Engine.config.external_resources_partials += ['example_resources/form']
