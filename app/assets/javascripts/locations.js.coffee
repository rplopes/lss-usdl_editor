# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $('.gn-id').each ->
    t = $(@)
    gn_id = /[0-9]+/.exec t.html()
    if gn_id
      $.ajax 'http://api.geonames.org/getJSON?geonameId='+gn_id+'&username=lss_usdl',
        type: 'GET'
        success: (data, textStatus, jqXHR) ->
          t.html data["name"]