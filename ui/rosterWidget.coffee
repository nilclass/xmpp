
window.rosterWidget = ->
  widget = div('roster-widget')

  createItem = (jid) ->
    item = div('item')
    jidDiv = div('jid').text(jid)
    item.append(jidDiv)
    item.append(div('status offline').attr('title', 'Offline'))
    actions = div('actions')
    chatBtn = button('Chat')
    chatBtn.click ->
      callAction 'conversation', 'start',
        jid: jid
    jidDiv.click ->
      actions.toggleClass 'visible'
    jidDiv.dblclick ->
      callAction 'conversation', 'start',
        jid: jid
    actions.append(chatBtn)
    item.append(actions)


  bindEvent 'roster_item', (evt) ->
    widget.append(createItem(evt.jid))

  callAction('roster', 'load')
  return widget
