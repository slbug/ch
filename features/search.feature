Feature: Room Search

  As a customer
  I want to search for available rooms
  So that I can book it

  @wip
  Scenario: successful search
    Given I am on the home page

    When I submit search form with valid data

    Then I should see the page for search results
    And I should see the list of hotels

