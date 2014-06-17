define(['line-chart'], (LineChart) ->
  convertMap2PointList = (map) ->
    list = []
    for x, y of map
      x = Math.max (parseInt x), 1e-6
      list.push x: x, y: y
    return list

  class Figure
    constructor: ->
     @outDegreeDistribution = new LineChart 'figure1', yLog: true
     @inDegreeDistribution = new LineChart 'figure2', yLog: true

    update: (graph) ->
      outDegree = convertMap2PointList graph.getOutDegreeDistribution()
      inDegree = convertMap2PointList graph.getInDegreeDistribution()

      @outDegreeDistribution.update outDegree
      @inDegreeDistribution.update inDegree
)
