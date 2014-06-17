define(['d3'], (d3) ->
  class LineChart
    @avoid_0_extent = (pointList, func) ->
      ori = d3.extent(pointList, func)
      if ori[0] <= 0
        ori[0] = 1e-6
      return ori

    @DEFAULT_CONFIGURE:
      width: 400
      height: 300
      xLog: false
      yLog: false

    @fillDefault: (configure) ->
      if not configure
        return LineChart.DEFAULT_CONFIGURE
      newConfigure = {}
      for key, value of LineChart.DEFAULT_CONFIGURE
        console.log key, value, configure[key]
        newConfigure[key] = configure[key] or value
      return newConfigure

    constructor: (parentId, configure) ->
      conf = LineChart.fillDefault configure
      d3Parent = d3.select "##{parentId}"
      margin =
        top: 20
        right: 20
        bottom: 30
        left: 50

      width = conf.width - margin.left - margin.right
      height = conf.height - margin.top - margin.bottom

      if conf.xLog
        @x = d3.scale.log()
          .range [0, width]
      else
        @x = d3.scale.linear()
          .range [0, width]
      if conf.yLog
        @y = d3.scale.log()
          .range [height, 0]
      else
        @y = d3.scale.linear()
          .range [height, 0]

      @xAxis = d3.svg.axis()
        .orient 'bottom'
        .scale(@x)

      @yAxis = d3.svg.axis()
        .orient 'left'
        .scale(@y)

      @line = d3.svg.line()
        .x( (d) => @x(d.x))
        .y( (d) => @y(d.y))

      @svg = d3Parent.append('svg')
        .attr('width', conf.width)
        .attr('height', conf.height)
        .append('g')
        .attr("transform", "translate(#{margin.left}, #{margin.top})")

      @svg.append('g')
        .attr('class', 'x axis')
        .attr('transform', "translate(0,#{height})")
        .call(@xAxis)

      @svg.append('g')
        .attr('class', 'y axis')
        .call(@yAxis)

      @path = @svg.append('path')
        .attr("class", "line")
      return

    update: (pointList) ->
      @x.domain(LineChart.avoid_0_extent(pointList, (d) -> d.x))
      @y.domain(LineChart.avoid_0_extent(pointList, (d) -> d.y))

      @xAxis.scale @x
      @yAxis.scale @y

      @svg.selectAll('.x.axis')
        .transition()
        .call(@xAxis)
      @svg.selectAll('.y.axis')
        .transition()
        .call(@yAxis)

      @path
        .datum(pointList)
        .transition()
        .attr("d", @line)
      return

  return LineChart
)
