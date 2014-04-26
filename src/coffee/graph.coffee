#globle var
g = {}

log = do ->
  ele = null
  return (text) ->
    if not ele
      ele = document.getElementById 'log-output'
    date = new Date()
    time = "#{date.getHours()}:#{date.getMinutes()}:#{date.getSeconds()}"
    ele.appendChild (document.createTextNode "[#{time}] #{text}\n")

    ele.scrollTop = ele.scrollHeight;
    return

async = (func) ->
  return setTimeout func, 0

convertMap2PointList = (map) ->
  list = []
  for x, y of map
    x = Math.max (parseInt x), 1e-6
    list.push x: x, y: y
  return list

avoid_0_extent = (pointList, func) ->
  ori = d3.extent(pointList, func)
  if ori[0] <= 0
    ori[0] = 1e-6
  return ori

update_lineChart = (handler, pointList) ->
  console.log handler
  handler.x.domain(avoid_0_extent(pointList, (d) -> d.x))
  handler.y.domain(avoid_0_extent(pointList, (d) -> d.y))

  handler.xAxis.scale handler.x
  handler.yAxis.scale handler.y

  handler.svg.selectAll('.x.axis')
    .transition()
    .call(handler.xAxis)
  handler.svg.selectAll('.y.axis')
    .transition()
    .call(handler.yAxis)

  handler.path
    .datum(pointList)
    .transition()
    .attr("d", handler.line)
  return


create_lineChart = (d3Parent, pointList, oWidth=400, oHeight=300) ->
  handler = {}
  margin =
    top: 20
    right: 20
    bottom: 30
    left: 50

  width = oWidth - margin.left - margin.right
  height = oHeight - margin.top - margin.bottom
  x = d3.scale.linear() # can be change to log
    .range [0, width]
  y = d3.scale.log()
    .range [height, 0]

  xAxis = d3.svg.axis()
    .orient 'bottom'
    .scale(x)

  yAxis = d3.svg.axis()
    .orient 'left'
    .scale(y)

  line = d3.svg.line()
    .x( (d) -> x(d.x))
    .y( (d) -> y(d.y))

  svg = d3Parent.append('svg')
    .attr('width', oWidth)
    .attr('height', oHeight)
    .append('g')
    .attr("transform", "translate(#{margin.left}, #{margin.top})")

  svg.append('g')
    .attr('class', 'x axis')
    .attr('transform', "translate(0,#{height})")
    .call(xAxis)

  svg.append('g')
    .attr('class', 'y axis')
    .call(yAxis)

  ###
    .append('text')
    .attr("transform", "rotate(-90)")
    .attr("y", 6)
    .attr("dy", ".71em")
    .style("text-anchor", "end")
    .text("Price ($)")
  ###

  path = svg.append('path')
    .attr("class", "line")

  handler =
    x: x
    y: y
    xAxis: xAxis
    yAxis: yAxis
    svg: svg
    line: line
    path: path

  update_lineChart handler, pointList

  return handler

getOutDegreeMap = (nodes) ->
  outDegreeeMap = {}
  for node in nodes
    count = node.dest.length
    outDegreeeMap[count] = ~~outDegreeeMap[count] + 1
  return outDegreeeMap

getInDegreeMap = (nodes) ->
  inDegreeeMap = {}
  for node in nodes
    count = node.src.length
    inDegreeeMap[count] = ~~inDegreeeMap[count] + 1
  return inDegreeeMap

generateGraph = (nodeNum, edgeNum) ->
  nodes = []
  for i in [0...nodeNum]
    nodes.push(
      id: i
      dest: []
      src: []
    )
  edge_left = edgeNum
  while true
    src = Math.floor(Math.random() * nodeNum)
    dest = Math.floor(Math.random() * nodeNum)
    if src == dest
      continue
    nodes[src].dest.push(dest)
    nodes[dest].src.push(src)
    edge_left -= 1
    if edge_left == 0
      break
  return nodes

#没解决重边问题
injectGraph = (graph, newSrcNum, newDestNum, destPerNode, camouflage, strategy) ->
  console.log 'hhaah'
  newSrcBegin = oldNodeNum = graph.length

  edgeToOldNodesNum = Math.floor (camouflage * destPerNode)
  newSrcEnd = newDestBegin = oldNodeNum + newSrcNum
  newDestEnd = oldNodeNum + newSrcNum + newDestNum

  for i in [newSrcBegin...newDestEnd]
    graph.push(
      id: i
      dest: []
      src: []
    )


  for src in [newSrcBegin...newSrcEnd]
    for i in [0...destPerNode]
      dest = Math.floor(Math.random() * newDestNum) + newDestBegin
      graph[src].dest.push(dest)
      graph[dest].src.push(src)
    for i in [0...edgeToOldNodesNum]
      if strategy is 'RAND'
        dest = Math.floor(Math.random() * oldNodeNum)
        graph[src].dest.push(dest)
        graph[dest].src.push(src)
      #else if strategy is 'POP'
        #TODO
  return graph

inputVal = (id) ->
  return parseInt ($ id).val()

# register listener
$ ->
  # init
  g.figure1 = create_lineChart (d3.select '#figure1'), []
  g.figure2 = create_lineChart (d3.select '#figure2'), []


  ($ '#inject-input-range').on 'change input', (e) ->
    ($ '#inject-range-show').text e.target.value

  ($ '#generate').on 'click', ->
    n = inputVal '#generate-input-n'
    e = inputVal '#generate-input-e'
    if n > 0 and e > 0
      log "Generating new graph, Nodes: #{n}, Edges: #{e}"
      async ->
        g.graph = generateGraph(n, e)

        log "Graph has been generated, building figure"
        async ->
          outDegree = convertMap2PointList (getOutDegreeMap g.graph)
          inDegree = convertMap2PointList (getInDegreeMap g.graph)
          
          update_lineChart g.figure1, outDegree
          update_lineChart g.figure2, inDegree

          log "All Done"

  ($ '#inject').on 'click', ->
    if not g.graph
      log "You need to *Generate* Graph first"
      return

    ($ '#inject').prop 'disabled', 'disabled'
    nSrc = inputVal '#inject-input-src'
    nDest = inputVal '#inject-input-dest'
    t = inputVal '#inject-input-t'
    d = inputVal '#inject-input-d'
    range = parseFloat ($ '#inject-input-range').val()


    log "Begin to Inject, Inject Button will be disabled"

    counter = t
    run = ->
      if counter
        log "Injecting Graph, No. #{t - counter + 1}"
      else
        ($ '#inject').prop 'disabled', null
        log "All Injecting Operations have been done, enable Inject Button"
        return

      async ->
        g.graph = injectGraph g.graph, nSrc, nDest, d, range, 'RAND'

        outDegree = convertMap2PointList (getOutDegreeMap g.graph)
        inDegree = convertMap2PointList (getInDegreeMap g.graph)
        
        update_lineChart g.figure1, outDegree
        update_lineChart g.figure2, inDegree

        counter -= 1
        log "Done, #{counter} times left"

        setTimeout run, 200

    async run
    return
