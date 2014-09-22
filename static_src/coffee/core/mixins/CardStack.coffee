define [
  'jquery'
  'underscore'
  'backbone'
],
($, _, Backbone) ->
  ###
  CardStack is a BackboneView mixin used to manage a stack of views where only one is meant to be 'active' at one time. Each
  card's DOM element is required to have an id and a class of 'card'.

  @type {Object}
  ###
  CardStack =
    $cards: null
    currentCardId: null
    previousCardId: null
    classToAdd: "js-card-stack"

    initializeCardStack : ->

      # do not proceeed if we've already initialized
      return if @$cards

      # Add a class of js-card-stack
      @$el.addClass @classToAdd

      # Cache cards
      @$cards = @getCards()
      @setupCards()
      @bindCardActions()

      return


    ###
    Get all of the cards for this card stack.

    This excludes and children cards of nested card stacks.

    @return {jQuery Elements} The cards
    ###
    getCards: ->

      # TODO: Haven't tested the performance implications of this loop
      $cardsToUse = $([])
      $cardsToExclude = $([])
      $allCards = @$(".card")

      # For every embedded card stack
      @$("." + @classToAdd).each ->
        # The current embedded card stack
        $el = $(this)

        # The cards within the embedded cardstack
        $innerCards = $el.find(".card")

        # Add the embedded cards
        $cardsToExclude = $cardsToExclude.add($innerCards)
        return


      # Exclude nested cards
      $cardsToUse = $allCards.not($cardsToExclude)
      @$cards = $cardsToUse
      @$cards


    ###
    Sets up cards by saving pointers to them in this.$cards, showing '.stack-cards.default', and hiding
    all other cards
    ###
    setupCards: ->
      defaultCard = undefined

      # confirm there are cards
      @switchToDefaultCard() if @$cards.length

    ###
    Bind special DOM elements to their associate card stack actions
    @return {[type]} [description]
    ###
    bindCardActions: ->
      # Search for any element within the view that contains 'data-card-next'
      @$el.on "click", "[data-card-next]", =>
        #Advance to next card
        @switchToNextCard()

      #  Search for any element within the view that contains 'data-card-previous'
      @$el.on "click", "[data-card-previous]", =>
        #Advance to previous card
        @switchToPreviousCard()

      # Search for any element within the view that contains 'data-card-id'
      @$el.on "click", "[data-card-id]", (evt) =>
        evt.preventDefault()

        card_id = $(evt.target).attr("data-card-id")
        before_method = "delegateSwitch#{card_id[0].toUpperCase()}#{card_id.substring(1)}"

        # Call the before_method if it exists
        if @[before_method]?
          @[before_method]?(card_id)
        # delegate method doesn't exist so switch the card
        else
          @switchToCard(card_id)

    switchToDefaultCard: ->

      # Search for a default card
      $specifiedDefaultCard = @$cards.filter(".default")

      # If a default has been specified use its id, otherwise use the id of the first card
      defaultCardId = (if $specifiedDefaultCard.length then $specifiedDefaultCard.attr("id") else @$cards.first().attr("id"))

      # Switch to a card with the id of the default card
      @switchToCard defaultCardId

    ###
    Switches to a specified card based on a jquery selector
    @param  {selector} cardId The selector of a card to be shown
    ###
    switchToCard: (cardId)->
      # get id from element if cardId is a view
      cardId = (if cardId.el? then cardId.el.id else cardId)
      $cardsToHide = @$cards.not("#" + cardId)
      $cardToShow = @$cards.filter("#" + cardId)

      # If card doesn't exist
      unless $cardToShow.length

        # Switch to default
        @switchToDefaultCard()
      else

        # Trigger 'hide-card' and 'hide-card[cardId]' event before transition
        $cardsToHide.each (n, el) =>
          if @previousCardId
            @trigger "hide-card", el.id
            @trigger "hide-card-" + el.id


        # Hide other cards
        $cardsToHide.removeClass("active").addClass "inactive"

        # Trigger 'show-card' and 'show-card-[cardId]' event before transition
        @trigger "show-card", cardId
        @trigger "show-card-" + cardId

        # Trigger 'hidden-card' and 'hidden-card[cardId]' event after transition
        $cardsToHide.each (n, el) =>
          if @previousCardId
            @trigger "hidden-card", el.id
            @trigger "hidden-card-" + el.id


        # Transition card
        $cardToShow.removeClass("inactive").addClass "active"

        # Update previousCardId and currentCardId
        @previousCardId = @currentCardId
        @currentCardId = cardId

        # Trigger 'showed-card' and 'showed-card-[cardId]' event after transition
        @trigger "showed-card", cardId
        @trigger "showed-card-" + cardId
      this


    ###
    Switches to the next card in the stack. If at the end of the stack, loop to
    the beginning of the stack.
    ###
    switchToNextCard: ->
      numberOfCards = @$cards.length
      $currentCard = $("#" + @currentCardId)
      currentIndex = @$cards.index($currentCard)

      # If the current card is the last card, move to the beginning of the stack
      nextIndex = (if (currentIndex is numberOfCards - 1) then 0 else currentIndex + 1)
      nextId = @$cards.eq(nextIndex).attr("id")

      #Switch to next card
      @switchToCard nextId
      this


    ###
    Switches to the next card in the stack. If at the end of the stack, loop to
    the beginning of the stack.
    ###
    switchToPreviousCard: ->
      numberOfCards = @$cards.length
      $currentCard = $("#" + @currentCardId)
      currentIndex = @$cards.index($currentCard)

      # If the current card is the first card, move to the end of the stack
      previousIndex = (if (currentIndex is 0) then numberOfCards - 1 else currentIndex - 1)
      previousId = @$cards.eq(previousIndex).attr("id")

      #Switch to next card
      @switchToCard previousId
      this


  #
  #    Todo: AutoCardStak (class & DOM-ready code) would be a good example of a module
  #    or to simply break it out into it's own .js file
  #

  ###
  A very thin view used for NoJS card stack implementations
  ###
  class AutoCardStack extends Backbone.View
    initialize: ->
      # Mixin CardStack
      _.defaults @, CardStack
      # Kick off initialize
      @initializeCardStack()

  # On page ready
  $ ->

    # Define global variable to store automated card stacks within
    AUTO_CARD_STACKS = {}

    # For every element with a class of 'js-auto-card-stack'
    $(".js-auto-card-stack").each (index, value) ->

      # Generate a unique id for the card stack
      $el = $ @
      viewId = "jsAutoCardStack" + index

      # If the element doesn't have an id already
      unless $el.attr("id")
        # Set it
        $el.attr "id", viewId
      else
        # Use the existing id
        viewId = $el.attr("id")

      # Create the new AutoCardStack view and add it to the global array
      AUTO_CARD_STACKS[viewId] = new AutoCardStack(el: "#" + viewId)

  # Export this mixin
  CardStack
