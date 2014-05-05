Feature: Blended Search
  In order to get various types of relevant government-related information from specific sites
  As a site visitor
  I want to be able to search for information

  Scenario: Simple search across news and indexed documents
    Given the following Affiliates exist:
      | display_name | name    | contact_email | contact_name | gets_blended_results    | is_rss_govbox_enabled |
      | bar site     | bar.gov | aff@bar.gov   | John Bar     | true                    | false                 |
    And affiliate "bar.gov" has the following RSS feeds:
      | name          | url                                  | is_navigable |
      | Press         | http://www.whitehouse.gov/feed/press | true         |
      | Blog          | http://www.whitehouse.gov/feed/blog  | true         |
    And feed "Press" has the following news items:
      | link                             | title               | guid       | published_ago | multiplier | description                                |
      | http://www.whitehouse.gov/news/1 | First <b> item </b> | pressuuid1 | day           | 1          | <i> item </i> First news item for the feed |
      | http://www.whitehouse.gov/news/2 | Second item         | pressuuid2 | day           | 1          | item Next news item for the feed           |
      | http://www.whitehouse.gov/news/9 | stale first item    | pressuuid9 | months        | 14         | item first Stale news item                 |
    And feed "Blog" has the following news items:
      | link                             | title               | guid       | published_ago | description                                |
      | http://www.whitehouse.gov/news/3 | Third item          | uuid3      | week          | item More news items for the feed          |
      | http://www.whitehouse.gov/news/4 | Fourth item         | uuid4      | week          | item Last news item for the feed           |
    And the following IndexedDocuments exist:
      | title                   | description                                  | url                 | affiliate  | last_crawled_at | last_crawl_status |
      | First petition article  | This is an article death star item petition  | http://p.whitehouse.gov/p-1.html | bar.gov | 11/02/2011      | OK      |
      | Second petition article | This is another article on the same item     | http://p.whitehouse.gov/p-2.html | bar.gov | 11/02/2011      | OK      |
    And the following Boosted Content entries exist for the affiliate "bar.gov"
      | url                                   | title             | description                                            |
      | http://bar.gov/hippopotamus-amphibius | Hippopotamus item | large, mostly herbivorous mammal in sub-Saharan Africa |
    And the following featured collections exist for the affiliate "bar.gov":
      | title           | status | publish_start_on |
      | featured item   | active | 2013-07-01       |
    And the following Twitter Profiles exist:
      | screen_name | name          | twitter_id | affiliate  |
      | USASearch   | USASearch.gov | 123456     | bar.gov    |
    And the following Tweets exist:
      | tweet_text                                                                                    | tweet_id | published_ago | twitter_profile_id | url                    | expanded_url            | display_url      |
      | "We wish you all a blessed and safe holiday item." - President Obama http://t.co/l8jbZSbmAX | 184957   | hour          | 123456             | http://t.co/l8jbZSbmAX | http://go.wh.gov/sgCp3q | go.wh.gov/sgCp3q |
    When I am on bar.gov's mobile search page
    And I fill in "Enter your search term" with "items"
    And I press "Search"
    Then I should see "<i> item </i> First news item for the feed"
    And I should see "item Next news item for the feed"
    And I should see "item first Stale news item"
    And I should see "item More news items for the feed"
    And I should see "item Last news item for the feed"
    And I should see "This is an article death star item petition"
    And I should see "This is another article on the same item"
    And I should see 1 Best Bets Text
    And I should see 1 Best Bets Graphic
    And I should see "blessed and safe"