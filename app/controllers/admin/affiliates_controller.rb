# frozen_string_literal: true

HIDDEN_COLUMNS = /(_created_at|
                   _updated_at|
                   agency_id|
                   css_properties|
                   content_type|
                   display_created_date_on_search_results|
                   display_filetype_on_search_results|
                   display_image_on_search_results|
                   display_updated_date_on_search_results|
                   file_name|
                   identifier_domain_name|
                   _image|
                   _json|
                   label|
                   _logo|
                   _mappings|
                   parent_agency_link|
                   parent_agency_name|
                   scope_ids|
                   size|
                   use_extended_header)\z/x

class Admin::AffiliatesController < Admin::AdminController
  active_scaffold :affiliate do |config|
    config.label = 'Sites'
    config.actions.exclude :delete, :search
    config.actions.add :field_search
    config.field_search.columns = :id, :name, :display_name, :website

    attribute_columns = config.columns.reject do |column|
      column.association or HIDDEN_COLUMNS.match?(column.name)
    end.map(&:name)
    attribute_columns << :agency
    attribute_columns.sort!

    all_columns = attribute_columns
    all_columns |= %i[mobile_logo_url]

    virtual_columns = %i[last_month_query_count
                         features
                         external_tracking_code
                         submitted_external_tracking_code
                         header_tagline_font_family
                         header_tagline_font_size
                         header_tagline_font_style
                         related_sites_dropdown_label
                         footer_fragment
                         recent_user_activity]

    all_columns |= virtual_columns
    config.columns = all_columns

    list_columns = %i[id display_name name website site_domains search_engine created_at updated_at recent_user_activity]
    config.list.columns = list_columns

    export_columns = [list_columns, all_columns].flatten.uniq
    actions.add :export
    config.export.columns = export_columns
    config.export.default_deselected_columns = %i[api_access_key
                                                  dc_contributor
                                                  dc_subject
                                                  dc_publisher
                                                  external_tracking_code
                                                  fetch_concurrency
                                                  footer_fragment
                                                  ga_web_property_id
                                                  header_tagline_font_family
                                                  header_tagline_font_size
                                                  header_tagline_font_style
                                                  last_month_query_count
                                                  navigation_dropdown_label
                                                  related_sites_dropdown_label
                                                  submitted_external_tracking_code
                                                  theme]

    config.list.sorting = { created_at: :desc }

    [:external_tracking_code, :submitted_external_tracking_code].each do |c|
      config.columns[c].form_ui = :textarea
    end

    update_columns = %i[
      active
      agency
      dap_enabled
      display_name
      domain_control_validation_code
      fetch_concurrency
      ga_web_property_id
      gets_blended_results
      gets_commercial_results_on_blended_search
      gets_i14y_results
      gets_results_from_all_domains
      i14y_date_stamp_enabled
      is_federal_register_document_govbox_enabled
      is_medline_govbox_enabled
      is_photo_govbox_enabled
      is_related_searches_enabled
      is_rss_govbox_enabled
      is_sayt_enabled
      is_video_govbox_enabled
      jobs_enabled
      locale
      name
      raw_log_access_enabled
      search_engine
      website
    ]
    config.update.columns = []
    enable_disable_column_regex = /^(is_|dap_enabled|gets_blended_results|gets_commercial_results_on_blended_search|jobs_enabled|raw_log_access_enabled|gets_i14y_results|gets_results_from_all_domains)/

    config.update.columns.add_subgroup 'Settings' do |name_group|
      name_group.add(*update_columns.grep_v(enable_disable_column_regex))
      name_group.add :affiliate_feature_addition, :excluded_domains, :i14y_memberships
      name_group.collapsed = true
    end

    config.update.columns.add_subgroup 'Enable/disable Settings' do |name_group|
      name_group.add(*update_columns.grep(enable_disable_column_regex))
      name_group.collapsed = true
    end

    config.update.columns.add_subgroup 'Display Settings' do |name_group|
      display_columns = %i[use_redesigned_results_page
                           show_search_filter_settings
                           looking_for_government_services
                           footer_fragment
                           header_tagline_font_family
                           header_tagline_font_size
                           header_tagline_font_style
                           no_results_pointer
                           page_one_more_results_pointer
                           navigation_dropdown_label
                           related_sites_dropdown_label]
      name_group.add(*display_columns)
      name_group.collapsed = true
    end

    config.update.columns.add_subgroup 'Analytics-Tracking Code' do |name_group|
      name_group.add :ga_web_property_id, :domain_control_validation_code,
                     :external_tracking_code, :submitted_external_tracking_code
      name_group.collapsed = true
    end

    config.action_links.add 'analytics', label: 'Analytics', type: :member, page: true

    show_columns = list_columns
    show_columns |= all_columns
    config.show.columns = show_columns

    config.create.columns = %i[
      display_name
      name
      website
      locale
    ]

    config.columns[:agency].form_ui = :select

    config.columns[:favicon_url].label = 'Favicon URL'
    config.columns[:features].associated_limit = nil

    config.columns[:footer_fragment].form_ui = :textarea

    config.columns[:header_tagline_font_family].form_ui = :select
    config.columns[:header_tagline_font_family].options = { options: HeaderTaglineFontFamily::ALL }

    config.columns[:header_tagline_font_size].description = 'Value should be in em. Default value: 1.3em'

    config.columns[:header_tagline_font_style].form_ui = :select
    config.columns[:header_tagline_font_style].options = { options: %w[italic normal] }

    config.columns[:locale].form_ui = :select
    config.columns[:locale].options = { options: Language.order(:name).pluck(:code) }

    config.columns[:mobile_logo_url].label = 'Logo URL'

    config.columns[:theme].form_ui = :select
    config.columns[:theme].options = { include_blank: '- select -',
                                       options: Affiliate::THEMES.keys }

    config.columns[:website].label = 'Homepage URL'
  end

  def analytics
    redirect_to new_site_queries_path(Affiliate.find(params[:id]))
  end
end
