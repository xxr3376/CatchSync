define ->
  class Logger
    constructor: (logElementId) ->
      @el = document.getElementById logElementId
    log: (text) ->
      date = new Date()
      time = "#{date.getHours()}:#{date.getMinutes()}:#{date.getSeconds()}"
      @el.appendChild (document.createTextNode "[#{time}] #{text}\n")

      @el.scrollTop = @el.scrollHeight
  return Logger
