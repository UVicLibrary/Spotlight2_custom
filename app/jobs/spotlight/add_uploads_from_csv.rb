# encoding: utf-8
# frozen_string_literal: true

require 'byebug'
require 'net/http'

module Spotlight
  ##
  # Process a CSV upload into new Spotlight::Resource::Upload objects
  class AddUploadsFromCSV < ActiveJob::Base
    queue_as :default

    after_perform do |job|
      csv_data, exhibit, user = job.arguments
      Spotlight::IndexingCompleteMailer.documents_indexed(csv_data, exhibit, user).deliver_now
    end

    def perform(csv_data, exhibit, _user)
      encoded_csv(csv_data).each do |row|
        url = row.delete('url')
        next unless url.present?

        # Check if there is actually a file at the URL


        # Use the IIIF Manifest importer
        if url.include?("vault.library.uvic.ca") && url.include?("manifest")
          if url.end_with?("manifest")
            url += ".json"
          end
          resource = Spotlight::Resources::IiifHarvester.new( url: url, exhibit_id: exhibit.id, file_name: "default.jpg", data: row)
          resource.save_and_index
          #byebug
          #resource.iiif_manifests.each do |manifest| # See /models/spotlight/resources/vault_iiif_manifest.rb
          #    manifest.with_exhibit(resource.exhibit)
          #    manifest.with_resource(resource)
          #    manifest_metadata = manifest.manifest_metadata.transform_values { |v| v.first }
          #    byebug
          #    #resource.data = manifest_metadata.merge(row) { |key, oldval, newval| "#{oldval}; #{newval}" } # We want to index the SolrDocument with a multiple value ({ k => ['v'] }
          #    resource.save_and_index
          #end

          #resource.reindex

        else

          resource = Spotlight::Resources::Upload.new(
            data: row,
            exhibit: exhibit
          )
          resource.build_upload(remote_image_url: url) unless url == '~'
          resource.save_and_index

        end
      end
    end

    private

    def encoded_csv(csv)
      csv.map do |row|
        row.map do |label, column|
          [label, column.encode('UTF-8', invalid: :replace, undef: :replace, replace: "\uFFFD")] if column.present?
        end.compact.to_h
      end.compact
    end
  end
end
