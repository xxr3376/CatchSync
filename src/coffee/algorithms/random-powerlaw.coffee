define ->
  return (graph, nodeNum, edgeNum) ->
    # call graph's newNode can create some nodes
    graph.newNode nodeNum

    edge_left = edgeNum
    while true
      # Here may create some duplicated edges
      src = Math.floor(Math.random() * nodeNum)
      dest = Math.floor(Math.random() * nodeNum)
      if src == dest
        continue
      # create a new edge
      graph.newEdge src, dest

      edge_left -= 1
      if edge_left == 0
        break
    return
