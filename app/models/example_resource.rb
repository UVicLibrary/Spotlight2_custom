class ExampleResource < Spotlight::Resource
  self.document_builder_class = ExampleBuilder
  store :data, accessors: [:values]
end
