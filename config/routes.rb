Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  concern :active_scaffold_association, ActiveScaffold::Routing::Association.new
  concern :active_scaffold, ActiveScaffold::Routing::Basic.new(association: true)
  get '/search' => 'searches#index', as: :search
  # SRCH-3494: Do not permit advanced search for sites using the SearchGov search engine
  constraints(AdvancedSearchesConstraint.new) do
    get '/search/advanced', to: redirect(path: '/search')
  end
  get '/search/advanced' => 'searches#advanced', as: :advanced_search
  get '/search/images' => 'image_searches#index', as: :image_search
  get '/search/docs' => 'searches#docs', as: :docs_search
  get '/search/news' => 'searches#news', as: :news_search
  # Provide some backward compatibility for searchers using the legacy video news search URL
  get '/search/news/videos', to: redirect(path: '/search')
  get '/auth/logindotgov/callback', to: 'omniauth_callbacks#login_dot_gov'

  # Deprecated
  get '/api/search' => 'api/v1/search#search', as: :api_search

  namespace :api, defaults: { format: :json } do
    namespace :v2 do
      get '/search' => 'searches#blended'
      get '/search/bing' => 'searches#bing'
      get '/search/i14y' => 'searches#i14y'
      get '/search/video' => 'searches#video'
      get '/search/docs' => 'searches#docs'
      post '/click' => 'click#create'
    end
  end

  post '/urls' => 'urls#create'
  get '/sayt' => 'sayt#index'
  post '/clicked' => 'clicked#create'
  get '/healthcheck' => 'health_checks#new'
  get '/up' => 'health_checks#new'
  get '/login' => 'user_sessions#security_notification', as: :login
  get '/signup' => 'user_sessions#security_notification', as: :signup
  get '/dcv/:affiliate.txt' => 'statuses#domain_control_validation',
    defaults: { format: :text },
    constraints: { affiliate: /.*/, format: :text }

  root to: 'user_sessions#security_notification'

  resource :account, controller: "users"

  resources :users do
    post 'update_account' => 'users#update_account'
  end

  resources :user_sites, only: [:index]

  resource :user_session
  resource :human_session, only: [:new, :create]

  scope module: 'sites' do
    resources :sites do
      member { put :pin }

      resource :alert, only: [:edit, :create, :update]

      resource :api_access_key, only: [:show]
      resource :api_instructions, only: [:show] do
        collection do
          get :commercial_keys
        end
      end
      resource :i14y_api_instructions, only: [:show]
      resource :type_ahead_api_instructions, only: [:show]
      resource :click_tracking_api_instructions, only: [:show]
      resource :clicks, only: [:new, :create]
      resource :query_clicks, only: [:show]
      resource :query_referrers, only: [:show]
      resource :query_downloads, only: [:show]
      resource :query_drilldowns, only: [:show]
      resource :click_drilldowns, only: [:show]
      resource :click_queries, only: [:show]
      resource :referrer_queries, only: [:show]
      resource :queries, only: [:new, :create]
      resource :referrers, only: [:new, :create]

      resource :content, only: [:show]
      resource :display, only: [:edit, :update] do
        collection { get :new_connection }
      end
      resource :visual_design, only: [:edit, :update]
      resources :links, only: :new
      resource :embed_code, only: [:show]
      resource :font_and_colors, only: [:edit, :update]
      resource :header_and_footer, only: [:edit, :update] do
        collection do
          get :new_footer_link
          get :new_header_link
        end
      end
      resource :image_assets, only: [:edit, :update]
      resource :no_results_pages, only: [:edit, :update] do
        collection do
          get :new_no_results_pages_alt_link
        end
      end
      resource :monthly_reports, only: [:show]
      resource :setting, only: [:edit, :update]
      resource :clone, only: [:new, :create]
      resource :supplemental_feed,
               controller: 'site_feed_urls',
               only: [:edit, :create, :update, :destroy]
      resource :third_party_tracking_request, only: [:new, :create]
      resource :autodiscovery, only: [:create]

      resources :best_bets_graphics, controller: 'featured_collections', except: [:show] do
        collection do
          get :new_keyword
          get :new_link
        end
      end

      resources :best_bets_texts, controller: 'boosted_contents', except: [:show] do
        collection do
          get :new_keyword
        end
      end

      resources :best_bets_texts_bulk_upload, controller: 'boosted_contents_bulk_uploads', only: [:new, :create]

      resources :collections, controller: 'document_collections' do
        collection { get :new_url_prefix }
      end
      resources :domains, controller: 'site_domains', except: [:show] do
        member { get :advanced }
      end
      resources :routed_queries do
        collection { get :new_routed_query_keyword }
      end
      resources :filter_urls,
                controller: 'excluded_urls',
                only: [:index, :new, :create, :destroy]
      resources :tag_filters, only: [:index, :new, :create, :destroy]
      resources :flickr_urls,
                controller: 'flickr_profiles',
                only: [:index, :new, :create, :destroy]
      resources :rss_feeds do
        collection { get :new_url }
      end
      resources :supplemental_urls,
                controller: 'indexed_documents',
                except: [:show, :edit, :update]
      resources :users, only: [:index, :new, :create, :destroy]
      resources :youtube_channels,
                controller: 'youtube_profiles',
                only: [:index, :new, :create, :destroy]
      resources :memberships, only: [:update]
      resources :i14y_drawers
      resource :filtered_analytics_toggle, only: :create
      resources :watchers
      resources :no_results_watchers, controller: "watchers", type: "NoResultsWatcher"
      resources :low_query_ctr_watchers, controller: "watchers", type: "LowQueryCtrWatcher"
    end
  end

  get '/help_docs' => 'help_docs#show'
  get '/affiliates', to: redirect('/sites')
  get '/affiliates/:id', to: redirect('/sites/%{id}')
  get '/affiliates/:id/:some_action', to: redirect('/sites/%{id}')

  namespace :admin do
    resources :affiliates, concerns: :active_scaffold
    resources :users, concerns: :active_scaffold
    resources :sayt_filters, concerns: :active_scaffold
    resources :sayt_suggestions, concerns: :active_scaffold
    resources :misspellings, concerns: :active_scaffold
    resources :affiliate_boosted_contents, concerns: :active_scaffold
    resources :document_collections, concerns: :active_scaffold
    resources :url_prefixes, concerns: :active_scaffold
    resources :catalog_prefixes, concerns: :active_scaffold
    resources :site_feed_urls, concerns: :active_scaffold
    resources :superfresh_urls, concerns: :active_scaffold
    resources :superfresh_urls_bulk_upload, only: :index do
      collection do
        post :upload
      end
    end
    resources :bulk_affiliate_delete, only: :index do
      collection do
        post :upload
      end
    end
    resources :bulk_affiliate_deactivate, only: :index do
      collection do
        post :upload
      end
    end
    resources :bulk_affiliate_search_engine_update, only: :index do
      collection do
        post :upload
      end
    end
    resources :bulk_url_upload, only: :index do
      collection do
        post :upload
      end
    end
    resources :bulk_affiliate_styles_upload, only: :index do
      collection do
        post :upload
      end
    end
    resources :bulk_affiliate_add, only: :index do
      collection do
        post :upload
      end
    end
    resources :odie_url_source_update, only: [:index] do
      collection do
        get :affiliate_lookup
        post :update_job
      end
    end
    resources :agencies, concerns: :active_scaffold
    resources :agency_organization_codes, concerns: :active_scaffold
    resources :federal_register_agencies, concerns: :active_scaffold do
      collection { get 'reimport' }
    end
    resources :federal_register_documents, concerns: :active_scaffold
    resources :search_modules, concerns: :active_scaffold
    resources :excluded_domains, concerns: :active_scaffold
    resources :affiliate_scopes, concerns: :active_scaffold
    resources :site_domains, concerns: :active_scaffold
    resources :features, concerns: :active_scaffold
    resources :affiliate_feature_additions, concerns: :active_scaffold
    resources :help_links, concerns: :active_scaffold
    resources :bing_urls, concerns: :active_scaffold
    resources :statuses, concerns: :active_scaffold
    resources :system_alerts, concerns: :active_scaffold
    resources :tags, concerns: :active_scaffold
    resources :trending_urls, only: :index
    resources :news_items, concerns: :active_scaffold
    resources :suggestion_blocks, concerns: :active_scaffold
    resources :rss_feeds, concerns: :active_scaffold
    resources :rss_feed_urls, concerns: :active_scaffold do
      member do
        get 'destroy_news_items'
        get 'news_items'
      end
    end
    resource :search_module_ctrs, only: [:show]
    resource :site_ctrs, only: [:show]
    resource :query_ctrs, only: [:show]
    resources :hints, concerns: :active_scaffold do
      collection { get 'reload_hints' }
    end
    resources :i14y_drawers, concerns: :active_scaffold
    resources :languages, concerns: :active_scaffold
    resources :routed_queries, concerns: :active_scaffold
    resources :routed_query_keywords, concerns: :active_scaffold
    resources :watchers, concerns: :active_scaffold
    resources :searchgov_domains, concerns: :active_scaffold do
      member do
        post 'reindex'
        post 'stop_indexing'
        get 'confirm_delete'
        delete 'delete_domain'
      end
      resources :searchgov_urls, concerns: :active_scaffold do
        member do
          post 'fetch'
        end
      end
      resources :sitemaps, concerns: :active_scaffold do
        member do
          post 'fetch'
        end
      end
    end

    mount Resque::Server.new, at: '/resque', constraints: AffiliateAdminConstraint
    get '/resque/(*all)', to: redirect(path: '/login')

    mount Sidekiq::Web => '/sidekiq', constraints: AffiliateAdminConstraint
  end

  match '/admin/affiliates/:id/analytics' => 'admin/affiliates#analytics', :as => :affiliate_analytics_redirect, via: :get
  match '/admin/site_domains/:id/trigger_crawl' => 'admin/site_domains#trigger_crawl', :as => :site_domain_trigger_crawl, via: :get
  match '/admin' => 'admin/home#index', :as => :admin_home_page, via: :get

  get '/superfresh' => 'superfresh#index', :as => :main_superfresh_feed
  get '/superfresh/:feed_id' => 'superfresh#index', :as => :superfresh_feed

  get '/user/developer_redirect' => 'users#developer_redirect', :as => :developer_redirect

  get '/program', to: redirect(BLOG_URL || '', status: 302)
  get '*path',    to: redirect(PAGE_NOT_FOUND_URL || '', status: 302), constraints: lambda { |req| req.path.exclude? 'rails/active_storage' }
end
