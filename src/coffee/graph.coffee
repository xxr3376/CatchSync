define(['type'], (Type) ->
  class Graph
    @NodeType = Type.createEnum ["NORMAL", "INJECT"]

    constructor: ->
      @nodes = []
      return

    clear: ->
      @nodes = []
      return

    # create #count nodes
    # All nodes contain "TYPE" Flag
    # return a list contain new nodes' id
    newNode: (count=1, type="NORMAL") ->
      start = @nodes.length
      for i in [0...count]
        node =
          id: start + i
          dest: []
          src: []
          type: Graph.NodeType[type]
        @nodes.push node
      return [start...start + count]

    newEdge: (src, dest) ->
      @nodes[src].dest.push(dest)
      @nodes[dest].src.push(src)
      return

    getOutDegreeDistribution: ->
      distribution = {}
      for node in @nodes
        count = node.dest.length
        distribution[count] = ~~distribution[count] + 1
      return distribution

    getInDegreeDistribution: ->
      distribution = {}
      for node in @nodes
        count = node.src.length
        distribution[count] = ~~distribution[count] + 1
      return distribution
  return Graph
)
