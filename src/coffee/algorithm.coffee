define( [
  'algorithms/inject',
  'algorithms/random-powerlaw',
  'algorithms/kronecker',
  'algorithms/erdos-renyi',
]
(
  inject,
  randomPowerlaw,
  kronecker,
  erdosRenyi,
) ->
  return {
    generate:
      randomPowerlaw: randomPowerlaw
      erdosRenyi: erdosRenyi
      kronecker: kronecker
    inject: inject
  }
)
