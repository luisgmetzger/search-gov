require 'forwardable'

class ImageSearch
  extend Forwardable
  include Pageable

  self.default_per_page = 20

  attr_reader :affiliate,
              :error_message,
              :module_tag,
              :modules,
              :query,
              :queried_at_seconds,
              :spelling_suggestion_eligible,
              :uses_cr

  def initialize(options = {})
    @options = options
    initialize_pageable_attributes(@options)

    @affiliate = @options[:affiliate]
    @modules = []
    @queried_at_seconds = Time.now.to_i
    @query = @options[:query]
    @uses_cr = @options[:cr].eql?('true') || @affiliate.has_no_social_image_feeds?
    @search_instance = initialize_search_instance(@uses_cr)
    @spelling_suggestion_eligible = !SuggestionBlock.exists?(query: @query)
  end

  def_instance_delegators :@search_instance,
                          :diagnostics,
                          :endrecord,
                          :results,
                          :startrecord,
                          :total

  def run
    return handle_empty_query if @query.blank?

    initialize_and_run_search
    reinitialize_and_run_search_if_needed
    assign_module_tag_if_results_present
  end

  def format_results
    return if results.blank?

    post_processor = ImageResultsPostProcessor.new(total, results)
    post_processor.normalized_results
  end

  def as_json(_options = {})
    if @error_message
      { error: @error_message }
    else
      { total:,
        startrecord:,
        endrecord:,
        results: }
    end
  end

  def spelling_suggestion
    return nil unless @spelling_suggestion_eligible

    @search_instance&.spelling_suggestion
    # SRCH-5169: BingV7ImageSearch is currently broken, resulting in @search_instance returning false. Since the
    # future of commercial image searches is uncertain, this addresses that scenario with a minimum of effort.
  end

  def commercial_results?
    %w[IMAG].include?(module_tag)
  end

  private

  def handle_empty_query
    @error_message = I18n.t(:empty_query)
  end

  def initialize_and_run_search
    @search_instance ||= initialize_search_instance(false)
    @search_instance.run
  end

  def reinitialize_and_run_search_if_needed
    return unless results.blank? && (@page == 1) && !@uses_cr

    @search_instance ||= initialize_search_instance(true)
    @search_instance.run
  end

  def assign_module_tag_if_results_present
    assign_module_tag if results.present?
  end

  def initialize_search_instance(uses_cr)
    params = search_params(uses_cr)
    OdieImageSearch.new(params)
  end

  def search_params(uses_cr)
    params = @options.slice(:affiliate, :query).merge(page: @page,
                                                      per_page: @per_page)
    params[:skip_log_serp_impressions] = true unless uses_cr
    params
  end

  def assign_module_tag
    @module_tag = @search_instance.default_module_tag
    @modules << @module_tag
    @modules << @search_instance.default_spelling_module_tag unless @search_instance.spelling_suggestion.nil?
  end
end
