class ExampleBuilder < Spotlight::SolrDocumentBuilder
  # def to_solr
  #   super.merge({ some: resource.values })
  #   # TIP: Make sure that your document's `unique_key` is the correct type.
  #   # (e.g. if `unique_key == :id`, you should not use `"id"` as your Hash key
  # end


      attr_reader :resource
      delegate :exhibit, :document_model, to: :resource

      def initialize(resource)
        @resource = resource
      end

      ##
      # @return an enumerator of all the indexable documents for this resource
      def documents_to_index
        data = to_solr
        return [] if data.blank?

        data &&= [data] if data.is_a? Hash

        return to_enum(:documents_to_index) { data.size } unless block_given?

        data.lazy.reject(&:blank?).each do |doc|
          yield doc.reverse_merge(exhibit_solr_doc(doc[unique_key]).to_solr)
        end
      end

      def spotlight_resource_metadata_for_solr
        {
          Spotlight::Engine.config.resource_global_id_field => (resource.to_global_id.to_s if resource.persisted?),
          document_model.resource_type_field => resource.class.to_s.tableize
        }
      end

  end
