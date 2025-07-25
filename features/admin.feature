Feature:  Administration
  Background:
    Given I am logged in with email "affiliate_admin@fixtures.org"

  Scenario: Visiting the admin home page as an admin
    When I go to the admin home page
    Then I should see the browser page titled "Super Admin"
    And I should see "Super Admin" in the page header
    And I should see "affiliate_admin@fixtures.org"
    And I should see "My Account"
    And I should see "Sign Out"

    When I follow "Super Admin" in the main navigation bar
    Then I should be on the admin home page

  Scenario: Visiting the admin home page as an admin who is also an affiliate
    Given "affiliate_admin@fixtures.org" is an affiliate
    When I go to the admin home page
    Then I should see "Super Admin" in the user menu
    And I should see "Admin Center" in the user menu

  Scenario: Visiting the affiliate admin page as an admin
    Given the following Affiliates exist:
      | display_name | name       | contact_email | first_name | last_name | website                | use_redesigned_results_page |
      | agency site  | agency.gov | one@foo.gov   | One        | Foo       | http://beta.agency.gov | false                       |
    And the following "site domains" exist for the affiliate agency.gov:
      | domain               | site_name      |
      | www1.agency-site.gov | Agency Website |
    When I go to the admin home page
    And I follow "Sites" within ".main"
    And I follow "Show" within the first scaffold row
    Then I should see "agency site (agency site) [Active]"
    When I follow "Close"
    Then I should see the following breadcrumbs: Super Admin > Sites
    And I should see "Display name"
    And I should see "Site Handle (visible to searchers in the URL)"
    And I should see "agency site"
    And I should see "agency.gov"
    And I should see "www1.agency-site.gov"
    And I should see "Search elastic"
    And I should see a link to "beta.agency.gov" with url for "http://beta.agency.gov"
    When I follow "www1.agency-site.gov"
    Then I should see "Agency Website"

  @javascript
  Scenario: Editing an affiliate as an admin
    Given the following Affiliates exist:
      | display_name | name       | contact_email | first_name | last_name | website                | use_redesigned_results_page |
      | agency site  | agency.gov | one@foo.gov   | One        | Foo       | http://beta.agency.gov | false                       |
    When I go to the admin sites page
    When I follow "Edit" within the first scaffold row
    Then I should see "Settings (Show)"
    And I should see "Enable/disable Settings (Show)"
    And I should see "Display Settings (Show)"
    And I should see "Analytics-Tracking Code (Show)"
    When I follow "Show" within the first subsection row
    And I fill in "Display name" with "New Name"
    And I press "Update"
    Then I should see "New Name"

  @javascript
  Scenario: Editing an affiliate's Display Settings as an admin
    Given the following Affiliates exist:
      | display_name | name       | contact_email | first_name | last_name | website                | use_redesigned_results_page |
      | agency site  | agency.gov | one@foo.gov   | One        | Foo       | http://beta.agency.gov | false                       |
    When I go to the admin sites page
    When I follow "Edit" within the first scaffold row
    Then I should see "Settings (Show)"
    And I should see "Enable/disable Settings (Show)"
    And I should see "Display Settings (Show)"
    And I should see "Analytics-Tracking Code (Show)"
    When I follow "Show" within the third subsection row
    And I check "Use redesigned results page"
    And I press "Update"
    Then I should see "agency site"
    When I follow "Edit" within the first scaffold row
    When I follow "Show" within the third subsection row
    And the "Use redesigned results page" checkbox should be checked

  Scenario: Visiting the users admin page as an admin
    When I go to the admin home page
    And I follow "Users" within ".main"
    Then I should be on the users admin page
    And I should see the following breadcrumbs: Super Admin > Users
    When I follow "Edit" within the first scaffold row
    Then the "Default affiliate" select field should contain 1 option

  Scenario: Visiting the SAYT Filters admin page as an admin
    When I go to the admin home page
    And I follow "Filters" within ".main"
    Then I should be on the sayt filters admin page
    And I should see the following breadcrumbs: Super Admin > Type Ahead Filters

  Scenario: Viewing Boosted Content (both affiliate and Search.USA.gov)
    Given the following Affiliates exist:
      | display_name | name    | contact_email | first_name | last_name | use_redesigned_results_page |
      | bar site     | bar.gov | aff@bar.gov   | John       | Bar       | false                       |
    And the following Boosted Content entries exist for the affiliate "bar.gov"
      | title              | url                    | description                        | keywords |
      | Bar Emergency Page | http://www.bar.gov/911 | This should not show up in results | safety   |
    When I go to the admin home page
    And I follow "Best Bets: Text"
    Then I should see the following breadcrumbs: Super Admin > Best Bets: Text
    And I should see "Bar Emergency Page"
    And I should not see "Our Emergency Page"
    When I follow "Show"
    Then I should see "safety"

  Scenario: Visiting the active scaffold pages
    When I go to the admin home page
    And I follow "Users"
    And I should see the following breadcrumbs: Super Admin > Users

    When I go to the admin home page
    And I follow "Rss Feeds"
    Then I should see "An Agency Feed"

    When I go to the admin home page
    And I follow "Rss Feed Urls"
    And I should see the following breadcrumbs: Super Admin > Rss Feed Urls
    When I follow "Show" within the first scaffold row
    Then I should see "http://another.agency.gov/feed"

    When I go to the admin home page
    And I follow "Filters"
    Then I should see the following breadcrumbs: Super Admin > Type Ahead Filters

    When I go to the admin home page
    And I follow "Suggestions"
    Then I should see the following breadcrumbs: Super Admin > Type Ahead Suggestions

    When I go to the admin home page
    And I follow "Misspellings"
    Then I should see the following breadcrumbs: Super Admin > Type Ahead Misspellings

    When I go to the admin home page
    And I follow "Best Bets: Text"
    Then I should see the following breadcrumbs: Super Admin > Best Bets: Text

    When I go to the admin home page
    And I follow "Collections"
    Then I should see the following breadcrumbs: Super Admin > Collections

    When I go to the admin home page
    And I follow "Superfresh Urls"
    Then I should see the following breadcrumbs: Super Admin > SuperfreshUrls

    When I go to the admin home page
    And I follow "Superfresh Bulk Upload"
    Then I should see the following breadcrumbs: Super Admin > Superfresh Bulk Upload

    When I go to the admin home page
    And I follow "Agencies"
    Then I should see the following breadcrumbs: Super Admin > Agencies

    When I go to the admin home page
    And I follow "Federal Register Agencies"
    Then I should see the following breadcrumbs: Super Admin > Federal Register Agencies

    When I go to the admin home page
    And I follow "Federal Register Documents"
    Then I should see the following breadcrumbs: Super Admin > Federal Register Documents

    When I go to the admin home page
    And I follow "Modules"
    Then I should see the following breadcrumbs: Super Admin > Modules

    When I go to the admin home page
    And I follow "Features" in the Super Admin page
    Then I should see the following breadcrumbs: Super Admin > Features

    When I go to the admin home page
    And I follow "Customer Scopes"
    Then I should see the following breadcrumbs: Super Admin > Customer Scopes

    When I go to the admin home page
    And I follow "Customer Catalog Prefix Whitelist"
    Then I should see the following breadcrumbs: Super Admin > Customer Catalog Prefix Whitelist

    When I go to the admin home page
    And I follow "Help Links"
    Then I should see the following breadcrumbs: Super Admin > HelpLinks

    When I go to the admin home page
    And I follow "Hints"
    Then I should see the following breadcrumbs: Super Admin > Hints

  @javascript
  Scenario: Managing Search.gov Domains
    Given the following "searchgov domains" exist:
      | domain     | status | canonical_domain |
      | search.gov | 200 OK |                  |
      | old.gov    | 200 OK | new.gov          |
    And the following "sitemaps" exist:
      | url                             |
      | https://search.gov/sitemap.xml  |
    When I go to the admin home page
    And I follow "Search.gov Domains"
    Then I should see the following breadcrumbs: Super Admin > Search.gov Domains
    And I should see "Export"
    And I should see "Search"
    And I should see "Create New"
    And I should see "Delete"
    And I should see "search.gov"
    And I should see "old.gov"
    And I should see "new.gov"
    And I should see "idle"

    When I follow "Sitemaps" within the first scaffold row
    Then I should see "search.gov/sitemap.xml"
    And I follow the first "Delete" and confirm in the SearchgovDomain Sitemaps table
    Then I should not see "search.gov/sitemap.xml"

    When I follow "Create New" in the SearchgovDomain Sitemaps table
    And I fill in "Url" with "search.gov/sitemap.txt"
    And I press "Create"
    Then I should see "search.gov/sitemap.txt"
    And I follow "Close"
    When I follow "Create New"
    And I fill in "Domain" with "www.state.gov"
    And I press "Create"
    Then I should see "www.state.gov has been created. Sitemaps will automatically begin indexing."

    When I follow "Reindex" within the first scaffold row and confirm "Are you sure you want to reindex this entire domain?"
    And I wait for ajax
    Then I should see "Reindexing has been enqueued for www.state.gov"

    When I follow "Edit" within the first scaffold row
    Then I should see "Render Javascript"
    When I check "Render Javascript"
    Then the "Render Javascript" checkbox should be checked
    And I press "Update"
    Then I should see "www.state.gov"

  @javascript
  Scenario: Managing Search.gov URLs
    Given the following "searchgov domains" exist:
      | domain     | status |
      | search.gov | 200 OK |
    And the following "searchgov urls" exist:
      | url                      |
      | https://search.gov/page1 |
    When I go to the admin home page
    And I follow "Search.gov Domains"
    And I follow "URLs" within the first scaffold row
    Then I should see "search.gov/page1"
    And I should see "Enqueued for reindex"

    When I follow "Fetch"
    And I wait for ajax
    Then I should see "Your URL has been added to the fetching queue"

    When I follow the first "Delete" and confirm in the SearchgovDomain URLs header
    Then I should not see "https://search.gov/page1"

    When I follow "Search" in the SearchgovDomain URLs table
    Then I should see "Enqueued for reindex" in the super admin search form

    When I follow "Delete" within the first scaffold row
    And I fill in "confirmation" with "DESTROY DOMAIN"
    And I press "Confirm Deletion"
    Then I should see "Deletion has been enqueued for search.gov"

  @javascript
  Scenario: Adding a system alert
    When I go to the admin home page
    And I follow "System Alerts"
    Then I should see the following breadcrumbs: Super Admin > System Alerts
    When I follow "Create New"
    And I fill in "Message" with "Achtung!"
    And I fill in "Start at" with "Sun, 26 Jul 2021 16:06:00"
    And I fill in "End at" with "Mon, 27 Jul 2021 16:06:00"
    And I press "Create"
    Then I should see "Achtung!"
    And I should see "1 Found"

  Scenario: Adding help link
    When I go to the admin home page
    And I follow "Help Link"
    And I follow "Create"
    And I fill in "Help page url" with "http://search.gov/edit_rss"
    And I fill in "Request path" with "http://localhost/affiliates/1/rss_feed/2/edit/?m=false"
    And I press "Create"
    Then I should see the following table rows:
      | Help page url              | Request path              |
      | http://search.gov/edit_rss | /affiliates/rss_feed/edit |
