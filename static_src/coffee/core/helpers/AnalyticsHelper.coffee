define ['facade'],
(facade) ->


  ###
    # A helper for setting up Google Analytics and tracking subsequent events via Google Analytics and KissMetrics.
  ###
  class AnalyticsHelper

    # Debugging variable
    isDebug = false

    dom_attrs :
      click  : 'ah-click'
      onload : 'ah-onload'
      type   : 'ah-type'
      types  :
        salesforce_field         : 'sf-field'
        universal_event          : 'universal-event'
        universal_category_event : 'universal-category-event'
        universal_page_view      : 'universal-page-view'
        event                    : 'event'
        category_event           : 'category-event'
        kmEvent                  : 'km-event'


    constructor: ->
        config =
          GOOGLE_ANALYTICS_ID    : 'abc' # TODO: encapsulate into constants.
          GOOGLE_ANALYTICS_DOMAIN: 'xyz' # TODO: encapsulate into constants.

        # Set google analytics properties
        @google_analytics_id     = config.GOOGLE_ANALYTICS_ID
        @google_analytics_domain = config.GOOGLE_ANALYTICS_DOMAIN

        # Default category to undefined
        @category = 'Undefined'

        # Load google analytics
        @loadGoogleAnalytics()

    ###*
     * Category setter
     * @param {string} @category The category of future uncategorized Google Analytics events logged via
     *                           `trackCategoryEvent`
    ###
    setCategory: (@category) ->

    ###*
     * Loads google analytics.
     *
     * From https://developers.google.com/analytics/devguides/collection/gajs/asyncTracking
    ###
    loadGoogleAnalytics: ->

        # Initialize _gaq if needed
        window._gaq = window._gaq || []

        _gaq.push(['_setAccount', @googlAnalyticsId])
        _gaq.push(['_setDomainName', @googleAnalyticsDomain])
        _gaq.push(['_trackPageview'])

        `(function() {
          var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
          ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
          var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
        })();`

        return

    ###*
     * Updates a field in Salesforce for the currently logged in user
     * @param  {string} field The salesforce field name
     * @param  {mixed}  value The value of the specified field
    ###
    updateSalesforceField: (field, value) ->
      # Grab the current user
      peopleId = window.Stik.user.info.int_people_id

      # Compile the request data
      requestData = {}
      requestData[field] = value

      # If the user is currently logged in
      if peopleId
          console.log("!!Analytics Log!!\n\n Salesforce Field::#{field} \nProperties::#{value}") if isDebug

          # Update salesforce
          request = $.ajax
            url : "/sfapi/v1/contacts/#{peopleId}/"
            type : "PUT"
            contentType: "application/json"
            data : JSON.stringify requestData

          # Log out when there's a failure
          request.fail ->
            console.log "There was a problem updating Salesforce" if isDebug


    ###*
     * Used to track an event via Google Analytics. Assumes a previously defined category set by `setCategory`.
     * If none is passed and none is defined by setCategory, the category will default to 'Undefined'
     * @param {string} action       The action of the event
     * @param {string} label        The label of the event
     * @param {int}    value        The integer value of the event
    ###
    trackCategoryEvent: (action, label, value) ->
        # Call track event
        @trackEvent(@category,action,label,value)
        return

    ###*
     * Used to track an event via Google Analytics
     * @param {string} category     The category (for Stik purposes, the page name/type).
     * @param {string} action       The action of the event
     * @param {string} label        The label of the event
     * @param {int}    value        The integer value of the event
    ###
    trackEvent: (category, action, label, value) ->
        # Track the event
        _gaq.push(['_trackEvent', category, action, label, value])
        # Uncomment to debug what events are being fired
        console.log("!!Analytics Log!!\n\nCategory::#{category} \nAction::#{action} \nLabel::#{label} \nValue::#{value}") if isDebug
        return

    ###*
     * Logs a Universal Tracking `pageview`
     * @param  {object} obj Should have key of "page" (which is a URI) and optional key "title"
    ###
    trackUniversalPageView: (obj) ->
        # Uncomment to debug what events are being fired
        console.log("!!Analytics Log!!\n\nOBJ::#{JSON.stringify(obj)}") if isDebug

        ga('send', 'pageview', obj)
        return

    ###*
     * Used to track an event in Universal Analytics
     * @param  {string} action The action of the event
     * @param  {string} label  The label of the event
     * @param  {int}    value  The integer value of the event
    ###
    trackUniversalCategoryEvent: (action, label=undefined, value=undefined) ->
        @trackUniversalEvent(@category, action, label, value) if @category?
        return

    ###*
     * Used to track an event in Universal Analytics
     * @param  {string} category   The category (for Stik purposes, the page name/type).
     * @param  {string} action     The action of the event
     * @param  {string} label      The label of the event
     * @param  {int} value         The integer value of the event
    ###
    trackUniversalEvent: (category, action, label=undefined, value=undefined) ->
        ga('send', 'event', category, action, label, value)
        # Uncomment to debug what events are being fired
        console.log("!!Analytics Log!!\n\nCategory::#{category} \nAction::#{action} \nLabel::#{label} \nValue::#{value}") if isDebug
        return

    setUserDimension: (people_id) ->
        @trackUniversalDimension(1, people_id)

    trackUniversalDimension: (dimensionIndex, value) ->
        ga('set', 'dimension' + dimensionIndex, value)
        return

    ###*
     * Used to track an event in Kissmetrics
     * @param  {string} name The name of the event in KM
    ###
    trackKmEvent: (name) ->
        Stik.KM.record(name)
        # Uncomment to debug when events are being fired
        console.log("!!Analytics Log!!\n\nName::#{name}") if isDebug

    ###*
     * Bind clicks on all elements with the attribute 'ah-click' appropriately
    ###
    bindClickEvents : ->
      # For every 'ah-click'
      for el in $("[#{@dom_attrs.click}]")
        $el = $(el)
        # Get all of the space-delimited types
        types = $el.attr('ah-type').split(" ")

        # For every event type
        for type in types
          # Preserve the context
          do ($el, type) =>
            # Bind a click event to perform the given type
            $el.on 'click', ()=>
              @performAnalyticsEvent($el, type)

    ###*
     * Execute all events tracked by 'ah-onload'
    ###
    handleOnloadEvents : ->
      # For every ah-onload
      for el in $("[#{@dom_attrs.onload}]")
        $el = $(el)
        # Get all of the space-delimited types
        types = $el.attr('ah-type').split(" ")

        # For every event type
        for type in types
          # Perform the given event
          @performAnalyticsEvent($el, type)

    ###*
     * Extract a hash of updateSalesforceField's parameters based on a given
     * jQuery DOM Element
     *
     * @param  {Element} $el The jQuery DOM Element that contains the "ah-*" attributes
     * @return {obj}     A hash, keyed on parameter name, of the given elements attribute values
    ###
    getSalesforceParametersFromElement : ($el)->
      attributeMap =
        'field' : 'ah-field'
        'value' : 'ah-value'

      # Scrape the value
      givenValue = $el.attr attributeMap['value']
      # For a value of "NOW" use the current timestamp, otherwise use the scraped value
      computedValue = if givenValue is "NOW" then moment().format() else givenValue

      # Attempt to scrape field and value attributes
      # and populate them into a return obj
      returnObj =
        field : $el.attr attributeMap['field']
        value : computedValue

    ###*
     * Extract a hash of trackUniversalEvent's parameters based on a given
     * jQuery DOM Element
     *
     * @param  {Element} $el The jQuery DOM Element that contains the "ah-*" attributes
     * @return {obj}     A hash, keyed on parameter name, of the given elements attribute values
    ###
    getUniversalEventParametersFromElement : ($el)->
      # For now, this is the same as getEventParametersFromElement
      # since trackEvent and trackUniversalEvent share the same parameters
      @getEventParametersFromElement($el)

    ###*
     * Extract a hash of trackUniveralPageView's parameters based on a given
     * jQuery DOM Element
     *
     * @param  {Element} $el The jQuery DOM Element that contains the "ah-*" attributes
     * @return {obj}     A hash, keyed on parameter name, of the given elements attribute values
    ###
    getUniversalPageViewParametersFromElement : ($el)->
      paramsObj =
        'obj' : undefined

      attributeMap =
        'obj'   : 'ah-obj'
        'page'  : 'ah-page'
        'title' : 'ah-title'

      # Attempt to scrape page and title attributes
      # and populate them into a return obj
      returnObj =
        page  : $el.attr attributeMap['page']
        title : $el.attr attributeMap['title']

      # Attempt to grab the 'ah-obj' attributes
      objString = $el.attr attributeMap['obj']
      # If the 'ah-obj' string exists
      if objString?
        # Parse the string into an object
        parsedObj = JSON.parse objString
        # Override the returnObj (ah-obj will always have more weight than ah-page or ah-title)
        returnObj = $el.attr parsedObj

      # Assemble parameter's object
      paramsObj['obj'] = returnObj

      # Return a hash, keyed on parameter name, of the given elements attribute values
      paramsObj


    ###*
     * Extract a hash of trackEvent's parameters based on a given
     * jQuery DOM Element
     *
     * @param  {Element} $el The jQuery DOM Element that contains the "ah-*" attributes
     * @return {obj}     A hash, keyed on parameter name, of the given elements attribute values
    ###
    getEventParametersFromElement : ($el)->
      parametersArray = {}
      attributeMap =
        'category'      : 'ah-category'
        'action'        : 'ah-action'
        'label'         : 'ah-label'
        'ga-value'      : 'ah-ga-value'

      # Return the parameters hash
      for parameter, attribute of attributeMap
        parametersArray[parameter] = $el.attr attribute

      parametersArray


    ###*
     * Extract a hash of trackKmEvent's parameters based on a given
     * jQuery DOM Element
     *
     * @param {Element} $el The jQuery DOM Element that contains the "ah-*" attributes
     * @return {obj}    A hash, keyed on parameter name, of the given elements attribute values
    ###
    getKmEventParametersFromElement : ($el)->
      parametersArray = {}
      attributeMap =
        'name'         : 'ah-name'

      # Return the parameters hash
      for parameter, attribute of attributeMap
        parametersArray[parameter] = $el.attr attribute

      parametersArray


    ###*
     * Performs any event given an Element and type
     * @param  {Element} $el         The element containing the tracking parameters
     * @param  {string} analyticType The type of tracking event
    ###
    performAnalyticsEvent : ($el, analyticType)->

      switch analyticType

        # For universal events
        when @dom_attrs.types.universal_event, @dom_attrs.types.universal_category_event
          # Get the parameters
          params = @getUniversalEventParametersFromElement $el

          # Execute the proper analytics method
          if analyticType is @dom_attrs.types.universal_event
            @trackUniversalEvent params['category'], params['action'], params['label'], params['ga-value']

          else if analyticType is @dom_attrs.types.universal_category_event
            @trackUniversalCategoryEvent params['action'], params['label'], params['ga-value']

        # For legacy Google Analytics events
        when @dom_attrs.types.event, @dom_attrs.types.category_event
          # Get the parameters
          params = @getEventParametersFromElement $el

          # Execute the proper analytics method
          if analyticType is @dom_attrs.types.event
            @trackEvent params['category'], params['action'], params['label'], params['ga-value']

          else if analyticType is @dom_attrs.types.category_event
            @trackCategoryEvent params['action'], params['label'], params['ga-value']

        # For universal page views
        when @dom_attrs.types.universal_page_view
          # Get the parameters
          params = @getUniversalPageViewParametersFromElement $el
          # Track the universal page view
          @trackUniversalPageView params['obj']

        # For Kissmetrics events
        when @dom_attrs.types.kmEvent
          # Get the parameters
          params = @getKmEventParametersFromElement $el
          # Record the KM event
          @trackKmEvent params['name']

        # For Salesforce fields
        when @dom_attrs.types.salesforce_field
          # Get the parameters
          params = @getSalesforceParametersFromElement $el
          # Update the Salesforce field
          @updateSalesforceField params['field'], params['value']



  # exports
  new AnalyticsHelper
