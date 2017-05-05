trainModels = function(learner, tasks, control) {
  # if (control$multifid)
  #   learner = makeMultiFidWrapper(learner, control)

  models = vector("list", length(tasks))
  secs = NA_real_
  tryCatch({
    start.time <- Sys.time()
    for (i in seq_along(models)) {
      models[[i]] = train(learner, tasks[[i]])
    }
    end.time <- Sys.time()
    secs <- end.time-start.time
  }, error = function(e) {
    print(e)
  })
  list(models = models, train.time = secs)
}
