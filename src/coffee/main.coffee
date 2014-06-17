define(['d3', 'jquery', 'logger', 'figure', 'graph', 'algorithm'], (d3, $, Logger, Figure, Graph, Algorithm) ->
  #globle var
  g = {}

  logger = new Logger 'log-output'

  async = (func) ->
    return setTimeout func, 0


  inputVal = (id) ->
    return parseInt ($ id).val()

  # register listener
  $ ->
    # init
    figure = new Figure()

    ($ '#inject-input-range').on 'change input', (e) ->
      ($ '#inject-range-show').text e.target.value

    ($ '#generate').on 'click', ->
      n = inputVal '#generate-input-n'
      e = inputVal '#generate-input-e'
      radio = ($ 'input[name="generate-method"]:radio:checked')
      method = radio.val()
      methodName = radio.parent().text().trim()

      if n > 0 and e > 0
        logger.log "Generating new graph using method: #{methodName}, Nodes: #{n}, Edges: #{e}"
        async ->
          g.graph = new Graph()
          Algorithm.generate[method] g.graph, n, e

          logger.log "Graph has been generated, building figure"
          figure.update g.graph
          logger.log "All Done"

    ($ '#inject').on 'click', ->
      if not g.graph
        logger.log "You need to *Generate* Graph first"
        return

      ($ '#inject').prop 'disabled', 'disabled'
      nSrc = inputVal '#inject-input-src'
      nDest = inputVal '#inject-input-dest'
      t = inputVal '#inject-input-t'
      d = inputVal '#inject-input-d'
      range = parseFloat ($ '#inject-input-range').val()


      logger.log "Begin to Inject, Inject Button will be disabled"

      counter = t
      run = ->
        if counter
          logger.log "Injecting Graph, No. #{t - counter + 1}"
        else
          ($ '#inject').prop 'disabled', null
          logger.log "All Injecting Operations have been done, enable Inject Button"
          return

        async ->
          Algorithm.inject g.graph, nSrc, nDest, d, range, 'RAND'

          figure.update g.graph

          counter -= 1
          logger.log "Done, #{counter} times left"

          setTimeout run, 200

      async run
      return
)
