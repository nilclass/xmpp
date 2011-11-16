
window.require = (name) ->
  $('head').append('<script src="' + "/" + name + '.js"></script')

$(document).ready ->
  require 'helpers'
  require 'socket'
  require 'connectWidget'
  require 'rosterWidget'
  require 'conversationWidget'

$(document).ready ->

  container = div('#container')

  window.logTarget = div('log-widget')
  container.append(logTarget)


  bindEvent 'exception', (exc) ->
    alert exc.message
    log(logTarget, exc.message, exc['class'])
    log(logTarget, exc.backtrace)

  bindEvent 'bound', (evt) ->
    log(logTarget, "Bound as: " + evt.jid)
    window.jid = evt.jid

  conversations = div('conversations')

  bindEvent 'ready', (evt) ->
    log(logTarget, "READY!")
    container.append(rosterWidget())
    container.append(conversations)

  messageBacklog = {}

  bindEvent 'start_conversation', (evt) ->
    messages = messageBacklog[evt.jid.split('/')[0]]
    conversations.append(
      conversationWidget(
        evt.jid, evt.id, messages
      )
    )

  bindEvent 'chat_message', (msg) ->
    if msg.id
      addMessageToConversation(msg.id, msg.from, msg.body)
    else
      bareJid = msg.from.split('/')[0]
      messageBacklog[bareJid] = [] unless 'bareJid' in messageBacklog
      messageBacklog[bareJid].push(msg)
      callAction 'conversation', 'start'
        jid: msg.from

  container.append(connectWidget())
  $(document.body).append(container)
