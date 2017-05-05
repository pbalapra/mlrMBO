library(devtools)
load_all("../../../mlrMBO/")
library(parallelMap)
library(smoof)
library(lhs)
library(optparse)

option_list = list(
  make_option(c("-s", "--seed"), type="numeric",  default = 0),
  make_option(c("-i", "--infill"), type="numeric", default = 2),
  make_option(c("-m", "--method"), type="numeric", default = 2),
  make_option(c("-p", "--point"), type="numeric", default = 0),
  make_option(c("-n", "--ndim"), type="numeric", default =2),
  make_option(c("-o", "--nobj"), type="numeric", default =2),
  make_option(c("-b", "--bsize"), type="numeric", default=30),
  make_option(c("-u", "--budget"), type="numeric", default=100),
  make_option(c("-t", "--tag"), type="character", default="00008-DTLZ1")
  );

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);



seed<-opt$seed
infill <-opt$infill
method <-opt$method
point<-opt$point
nobj<-opt$nobj
ndim<-opt$ndim
bsize<-opt$bsize
budget<-opt$budget
tag<-opt$tag
filename<-sprintf("../results/%s-%05d-%05d-%05d-%05d-%05d-%05d-%05d-%05d.rds",tag,seed,nobj,ndim,bsize,budget,infill,method,point)
#print(filename)
#print(opt)

tryCatch({
  set.seed(opt$seed)
  obj.fun<-makeDTLZ1Function(ndim, nobj)
  print(obj.fun)

  ctrl = makeMBOControl(n.objectives = nobj, propose.points = bsize)
  ctrl = setMBOControlTermination(ctrl, max.evals = budget)

  # infill
  if(infill == 1){
    ctrl = setMBOControlInfill(ctrl, crit =makeMBOInfillCritMeanResponse())
  } else if(infill == 2){
    ctrl = setMBOControlInfill(ctrl, crit =makeMBOInfillCritStandardError())
  } else if(infill == 3){
    ctrl = setMBOControlInfill(ctrl, crit =makeMBOInfillCritEI())
  } else if(infill == 4){
    ctrl = setMBOControlInfill(ctrl, crit =makeMBOInfillCritCB())
  } else {
    ctrl = setMBOControlInfill(ctrl, crit =makeMBOInfillCritDIB())
  }

  # method to use
  if(method == 1){
    ctrl = setMBOControlMultiObj(ctrl, method = "parego")
  } else if(method == 2){
    ctrl = setMBOControlInfill(ctrl, opt = "nsga2")
    ctrl = setMBOControlMultiObj(ctrl, method = "mspot")
  } else {
    ctrl = setMBOControlMultiObj(ctrl, method = "dib")
  }

  # multipoint strategy
  if(point == 1){
    #“moimbo”: Proposes points by multi-objective infill criteria via evolutionary multi-objective optimization.
    #The EA is a (mu+1) type of algorithm and runs for moimbo.maxit generations. The population size is set to
    #propose.points. The selection criterion is moimbo.selection. If this method is selected the infill criterion in
    #setMBOInfillCrit is ignored.
    ctrl = setMBOControlMultiPoint(ctrl, method = "moimbo") # IMPORTANT: setMBOInfillCrit is ignored.
  } else if(point == 2){
    #“cl”: Proposes points by constant liar strategy. Only meaningfull if infill.crit == "cb" In the first step
    #the kriging model is fitted based on the real data and the best point is calculated according to the regular
    #EI-criterion. Then, the function value of the best point is simply guessed by the worst seen function evaluation.
    #This lie is used to update the model in order to propose the subsequent point. The procedure is applied until the
    #number of best points achieves propose.points.
    ctrl = setMBOControlMultiPoint(ctrl, method = "cl") # IMPORTANT: Only meaningfull if infill.crit == "cb"
  } else {
    #“cb”: Proposes points by optimizing the confidence bound “cb” criterion, propose.points times. Each
    # lambda value for “cb” is drawn randomly from an exp(1)-distribution, so do not define infill.opt.cb.lambda.
    # The optimizer for each proposal is configured in the same way as for the single point case, i. e., by
    #specifying infill.opt and related stuff.
    ctrl = setMBOControlMultiPoint(ctrl, method = "cb")
  }

  des = generateDesign(ndim+1, getParamSet(obj.fun), fun = lhs::maximinLHS)

  #surr.km = makeLearner("regr.km", predict.type = "se", covtype = "matern3_2", control = list(trace = FALSE))
  surr.km = makeLearner("regr.bgp", predict.type = "se")

  run = mbo(obj.fun, design=des, learner = surr.km, control = ctrl, show.info = TRUE)
  saveRDS(run, filename)

}, error = function(e) print(e))

