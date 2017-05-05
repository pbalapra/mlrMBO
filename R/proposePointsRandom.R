# Proposes n points randomly by calling generateRandomDesign.
# crit.vals, propose.time and errors.model are all set to NA
proposePointsRandom = function(opt.state, nb = 0) {
  opt.problem = getOptStateOptProblem(opt.state)
  control = getOptProblemControl(opt.problem)
  par.set = getOptProblemParSet(opt.problem)
  n = control$interleave.random.points
  n = max(n, nb)
  readline(prompt="proposePoints.R 2a. Press [enter] to continue")
  prop.points = generateRandomDesign(par.set = par.set, n)
  print(prop.points)
  crit.vals = matrix(rep.int(0, n), nrow = n, ncol = 1L)
  print(is.matrix(crit.vals))
  list(
    prop.points = prop.points,
    crit.vals = crit.vals,
    propose.time = rep.int(NA_real_, n),
    prop.type = rep("random_interleave", n),
    errors.model = rep.int(NA_character_, n)
  )
}
