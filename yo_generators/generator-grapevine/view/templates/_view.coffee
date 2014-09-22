define [
  'facade'
  'BaseView'
],
(facade, BaseView) ->


  class <%= name_view %> extends BaseView

    initialize: (settings={}) ->
      # install sandbox to view
      @sandbox ?= facade.installTo {}, '<%= id %>'

      # set values
      @sandbox.value greeting: 'Allo'

      # initial welcome
      @sandbox.on      'welcome', @handleWelcome, @
      @sandbox.trigger 'welcome', '<%= name_view %>'



    ###*
     * Event Handlers
    ###
    handleWelcome: ->
      greeting = @sandbox.value().greeting
      console?.log "#{greeting}, <%= name_view %>, and welcome!!"


  # exports
  <%= name_view %>
