convertMap2PointList = (map) ->
  list = []
  for x, y of map
    list.push x: (parseInt x), y: y
  return list

create_lineChart = (d3Parent, pointList, oWidth=400, oHeight=300) ->
  console.log pointList
  margin =
    top: 20
    right: 20
    bottom: 30
    left: 50

  width = oWidth - margin.left - margin.right
  height = oHeight - margin.top - margin.bottom
  x = d3.scale.linear()
    .range [0, width]
  y = d3.scale.log()
    .range [height, 0]

  x.domain(d3.extent(pointList, (d) -> d.x))
  y.domain(d3.extent(pointList, (d) -> d.y))

  xAxis = d3.svg.axis()
    .scale(x)
    .orient 'bottom'

  yAxis = d3.svg.axis()
    .scale(y)
    .orient 'left'

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
    .append('text')
    .attr("transform", "rotate(-90)")
    .attr("y", 6)
    .attr("dy", ".71em")
    .style("text-anchor", "end")
    .text("Price ($)")

  svg.append('path')
    .datum(pointList)
    .attr("class", "line")
    .attr("d", line)


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

console.time('xxx')
nodes = []
total= 1e2
for i in [0..total]
  nodes.push(
    id: i
    dest: []
    src: []
  )
edge_left = total * 3
while true
  src = Math.floor(Math.random() * total)
  dest = Math.floor(Math.random() * total)
  if src == dest
    continue
  nodes[src].dest.push(dest)
  nodes[dest].src.push(src)
  edge_left -= 1
  if edge_left == 0
    break

console.timeEnd('xxx')

console.time 'out degress calculate'
pointList = convertMap2PointList (getOutDegreeMap nodes)
create_lineChart (d3.select '#figure1'), pointList

pointList = convertMap2PointList (getInDegreeMap nodes)
create_lineChart (d3.select '#figure2'), pointList
console.timeEnd 'out degress calculate'
