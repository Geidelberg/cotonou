#' @export
#' @useDynLib cotonou
return_outputs <- function(p, gen, time, outputs) {
  mod <- gen(user = p)
  all_results <- mod$transform_variables(mod$run(time))
  #   all_results[c("prev", "c_comm_balanced", "c_noncomm_balanced", "c_comm", "c_noncomm", "epsilon")]
  return(all_results[outputs])
}

#' @export
#' @useDynLib cotonou
likelihood_rough <- function(x, time, prev_points) {
  the_prev = data.frame(time, x$prev_FSW, x$prev_LowFSW, x$prev_client, x$prev_women, x$prev_men)
  names(the_prev) = c("time", "Pro FSW", "Low-level FSW", "Clients", "Women", "Men")

  likelihood_count <- 0

  # point_test = c()

  for(i in 1:length(prev_points[,1]))
  {

    point = subset(the_prev, time = prev_points[i, "time"], select = as.character(prev_points[i, "variable"]))
    if(!is.na(point)) {if((point < prev_points[i, "upper"]) && (point > prev_points[i, "lower"]))
    {
      # print(prev_points[i, c("time", "variable")]);
      likelihood_count <- likelihood_count + 1
    }}

    # point_test = c(point_test, point)
  }

  # return (point_test)


  return (likelihood_count)

}

#' @export
#' @useDynLib cotonou
run_on_cluster <- function(number_simulations, par_seq, condom_seq, groups_seq, years_seq, best_set, time, ranges, outputs, prev_points) {


  # parameters --------------------------------------------------------------
  parameters <- cotonou::lhs_parameters(number_simulations, set_pars = best_set, Ncat = 9, time = time,
                                        ranges = ranges, par_seq = par_seq, condom_seq = condom_seq, groups_seq = groups_seq, years_seq = years_seq)
  # end of parameters --------------------------------------------------------------


  res = lapply(parameters, return_outputs, main_model, time = time, outputs = outputs)


  #test
  # return(lapply(res, likelihood_rough, time = time, prev_points = prev_points))

  likelihood_list = unlist(lapply(res, likelihood_rough, time = time, prev_points = prev_points))
  sorted_likelihood_list = sort(likelihood_list)


  best_runs = which(likelihood_list == max(sorted_likelihood_list))

  out <- res[best_runs]

  # return(likelihood_list)
  return(out)

}