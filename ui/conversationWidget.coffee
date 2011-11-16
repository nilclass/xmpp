
window.addMessageToConversation = (id, from, body) ->
  w = $('.conversation-widget[data-id=' + id + ']')
  msg = div('message')
  lp = from.split('@')[0]
  msg.append(div('from').text(lp).attr('title', jid))
  msg.append(div('body').text(body))
  msgs = w.find('.messages')
  msgs.append(msg)
  msgs.scrollTop msgs.prop("scrollHeight")

window.conversationWidget = (jid, id, messageStack) ->
  widget = div('conversation-widget')
  widget.attr('data-id', id)
  header = $('<header>Conversation with ' + jid + '</header>')
  widget.append(header)

  messages = div('messages')
  widget.append(messages)

  addMessageToConversation(id, message.from, message.body) for message in messageStack if messageStack

  footer = $('<footer></footer>')
  msg = div('message')
  lp = window.jid.split('@')[0]
  msg.append(div('from').text(lp).attr('title', window.jid))
  form = $('<form></form')
  body = input('body').addClass('body')
  form.append(body)
  form.submit ->
    callAction 'conversation', 'say'
      body: body.val()
      to: jid
    body.val('')
    return false
  msg.append(form)
  footer.append(msg)
  widget.append(footer)

  header.click ->
    messages.toggleClass('hidden')
    footer.toggleClass('hidden')

  return widget
