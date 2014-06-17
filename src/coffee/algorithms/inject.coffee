define(['underscore'], (_) ->

  #using underscore's sample could be very slow...
  sampleInt = (lower, upper, k) ->
    if upper - lower < k
      throw 'Sample population is smaller than sample'
    result = {}
    range = upper - lower
    count = 0
    while count < k
      cur = Math.floor(Math.random() * range) + lower
      if not result[cur]
        result[cur] = 1
        count += 1
    return Object.keys result

  injectGraph = (graph, newSrcNum, newDestNum, destPerNode, camouflage, strategy) ->
    oldNodesNum = graph.nodes.length
    edgeToOldNodesNum = Math.floor (camouflage * destPerNode)

    # create new nodes
    newSrc = graph.newNode newSrcNum
    newDest = graph.newNode newDestNum

    for src in newSrc
      # create edges between newSrc to newDest
      targets = _.sample newDest, destPerNode
      for dest in targets
        graph.newEdge src, dest

      # create edges between newSrc to oldNodes
      if strategy is 'RAND'
        # use sampleInt to accelerate
        targets = sampleInt 0, oldNodesNum, edgeToOldNodesNum

        for dest in targets
          graph.newEdge src, dest
      #else if strategy is 'POP'
        #TODO
    return

  return injectGraph
)
