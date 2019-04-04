Rails.application.routes.draw do

  mount Blacklight::Oembed::Engine, at: 'oembed'
  mount Riiif::Engine => '/images', as: 'riiif'
  root to: 'spotlight/exhibits#index'
  mount Spotlight::Engine, at: 'spotlight'
  mount Blacklight::Engine => '/'


#  root to: "catalog#index" # replaced by spotlight root path
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end
  devise_for :users
  concern :exportable, Blacklight::Routes::Exportable.new

  # Force a route for /:exhibit_id/catalog/:id/manifest(.json)
  # resources :solr_documents, only: [:show, :destroy], path: '/catalog', controller: 'catalog' do
  #   concerns :exportable
  # end
  resources :solr_documents, except: [:index], path: '/catalog', controller: 'catalog' do
    concerns :exportable

    member do
      put 'visibility', action: 'make_public'
      delete 'visibility', action: 'make_private'
      get 'manifest'
    end
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  get "/spotlight/:exhibit_id/new_manifest", to: "spotlight/resources#new_manifest", as: :new_manifest
  get "/spotlight/:exhibit_id/map", to: "spotlight/resources#google_map", as: :map
  get "/spotlight/:exhibit_id/catalog/:id/mirador_fullscreen", to: "spotlight/catalog#mirador_fullscreen", as: :manifest_fullscreen

end

Spotlight::Engine.routes.draw do

  mount Annotot::Engine, at: 'annotations'
end
