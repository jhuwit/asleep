

transform_data_to_files = function(file, verbose = TRUE) {
  if (verbose) {
    message("Checking Data")
  }

  # single df
  if (is.data.frame(file)) {
    if (verbose) {
      message("Writing file to CSV...")
    }
    tfile = tempfile(fileext = ".csv")
    file = sl_write_csv(data = file, path = tfile)
    attr(file, "remove_file") = TRUE
  }

  if (
    # a list of files
    (is.character(file) &&
     all(sapply(file, assertthat::is.readable))) ||
    # could be list of dfs
    is.list(file) ) {
    file = lapply(file, function(f) {
      if (is.data.frame(f)) {
        if (verbose) {
          message("Writing file to CSV...")
        }
        tfile = tempfile(fileext = ".csv")
        f = sl_write_csv(data = f, path = tfile)
        attr(f, "remove_file") = TRUE
      }
      f
    })
    names(file) = file
  }
  return(file)
}



summarize_daily_sleep = function(sdf) {
  get_mean_median = function(x) {
    x %>%
      dplyr::select(-dplyr::any_of("wear_duration_H")) %>%
      dplyr::summarise(
        dplyr::across(
          dplyr::where(is.numeric), list(
            mean = ~ mean(.x, na.rm = TRUE),
            median = ~ median(.x, na.rm = TRUE)
          )))
  }
  prefix = day_of_week = is_weekend = NULL
  rm(list = c("day_of_week", "prefix", "is_weekend"))

  sdf = sdf %>%
    dplyr::mutate(
      day_of_week = as.character(day_of_week),
      day_of_week = dplyr::case_match(
        day_of_week,
        "0" ~ "Monday",
        "1" ~ "Tuesday",
        "2" ~ "Wednesday",
        "3" ~ "Thursday",
        "4" ~ "Friday",
        "5" ~ "Saturday",
        "6" ~ "Sunday"
      ))

  overall = sdf %>%
    get_mean_median()
  if (nrow(overall) > 0) {
    overall = overall %>%
      dplyr::mutate(prefix = "overall") %>%
      dplyr::select(prefix, dplyr::everything())
  }

  dow = sdf %>%
    dplyr::group_by(day_of_week) %>%
    get_mean_median() %>%
    dplyr::rename(prefix = day_of_week) %>%
    dplyr::select(prefix, dplyr::everything())

  we = sdf %>%
    dplyr::group_by(is_weekend) %>%
    get_mean_median() %>%
    dplyr::mutate(is_weekend = ifelse(is_weekend, "weekend", "weekday")) %>%
    dplyr::rename(prefix = is_weekend) %>%
    dplyr::mutate(prefix = as.character(prefix)) %>%
    dplyr::select(prefix, dplyr::everything())

  result = dplyr::bind_rows(overall, dow, we)
  return(result)
}


#' Run `asleep` Model on Data
#'
#'
#' @param file accelerometry file to process, including CSV,
#' CWA, GT3X, and `GENEActiv` bin files
#' @param pytorch_device device to use for prediction for PyTorch.
#' @param verbose print diagnostic messages
#' @inheritParams sl_load_model
#' @param outdir output directory for CSVs and outputs
#' @param min_wear_hours Min wear time in hours to be eligible for summary statistics computation.
#' The sleepnet paper uses 22
#' @param time_shift The number hours to shift forward or backward from
#' the current device time. e.g. +1 or -1
#' @param report_light_and_temp If true, it adds mean temp, and light columns to the predictions
#'
#' @returns A list of outputs, including summaries, paths, and dataframes.
#' @export
#'
#' @examples
#' file = system.file("extdata/example_sleep.csv.gz", package = "stepcount")
#' if (asleep_check()) {
#'   out = asleep(file = file)
#'   pred = out$predictions
#' }
#' \dontrun{
#'   file = system.file("extdata/example_sleep.csv.gz", package = "stepcount")
#'   df = readr::read_csv(file)
#'   if (asleep_check()) {
#'     out = stepcount(file = df)
#'     st = out$step_times
#'   }
#'   if (requireNamespace("ggplot2", quietly = TRUE) &&
#'       requireNamespace("tidyr", quietly = TRUE) &&
#'       requireNamespace("dplyr", quietly = TRUE)) {
#'     dat = df[10000:12000,] %>%
#'       dplyr::select(-annotation) %>%
#'       tidyr::gather(axis, value, -time)
#'     st = st %>%
#'       dplyr::mutate(time = lubridate::as_datetime(time)) %>%
#'       dplyr::as_tibble()
#'     st = st %>%
#'       dplyr::filter(time >= min(dat$time) & time <= max(dat$time))
#'     dat %>%
#'       ggplot2::ggplot(ggplot2::aes(x = time, y = value, colour = axis)) +
#'       ggplot2::geom_line() +
#'       ggplot2::geom_vline(data = st, ggplot2::aes(xintercept = time))
#'   }
#'
#' }
asleep = function(
    file,
    outdir = NULL,
    model_path = NULL,
    min_wear_hours = 22L,
    time_shift = "0",
    report_light_and_temp = FALSE,
    pytorch_device = c("cpu", "cuda:0"),
    verbose = TRUE
) {

  try({
    hc = reticulate::import("hydra.core")
    hc_inst = hc$global_hydra$GlobalHydra$instance()
    hc_inst$clear()
  }, silent = TRUE)

  assertthat::assert_that(
    assertthat::is.string(time_shift),
    assertthat::is.count(min_wear_hours)
  )
  min_wear = as.integer(min_wear_hours)
  if (is.null(outdir)) {
    outdir = tempfile()
  }
  dir.create(outdir, recursive = TRUE, showWarnings = FALSE)
  outdir = normalizePath(outdir, mustWork = TRUE)


  pytorch_device = match.arg(pytorch_device, choices = c("cpu", "cuda:0"))
  resample_hz = 30L

  argparse = reticulate::import("argparse", convert = FALSE)
  args <- argparse$Namespace
  args$outdir = outdir
  args$force_download = FALSE
  args$force_run = FALSE
  args$remove_intermediate_files = FALSE
  args$report_light_and_temp = report_light_and_temp
  # help="Pytorch device to use, e.g.: 'cpu' or 'cuda:0' (for SSL only)",
  args$pytorch_device = pytorch_device
  if (is.null(model_path)) {
    model_weight_path = ""
  } else {
    model_weight_path = normalizePath(path.expand(model_path))
  }
  args$model_weight_path = model_weight_path
  args$local_repo_path = ""
  args$min_wear = min_wear
  args$time_shift = time_shift


  # Working on filenames
  file = transform_data_to_files(file = file, verbose = verbose)
  remove_file = attr(file, "remove_file")
  if (length(file) == 1 &&
      !is.null(remove_file) &&
      remove_file) {
    on.exit({
      file.remove(file)
    }, add = TRUE)
  }
  file = file[[1]]
  #
  file = normalizePath(path.expand(file), mustWork = TRUE)
  args$filepath = file

  abase_noconvert = reticulate::import("asleep", convert = FALSE)

  # raw_data_path = tempfile(fileext = "raw.csv")
  # info_data_path = tempfile(fileext = "info.json")
  # data2model_path = tempfile(fileext = "data2model.npy")
  # times_path = tempfile(fileext = "times.npy")
  # non_wear_path = tempfile(fileext = "non_wear.npy")
  # day_summary_path = tempfile(fileext = "day_summary.csv")
  # output_json_path = tempfile(fileext = "summary.json")

  raw_data_path = file.path(outdir, "raw.csv")
  info_data_path = file.path(outdir, "info.json")
  data2model_path = file.path(outdir, "data2model.npy")
  times_path = file.path(outdir, "times.npy")
  non_wear_path = file.path(outdir, "non_wear.npy")
  day_summary_path = file.path(outdir, "day_summary.csv")
  output_json_path = file.path(outdir, "summary.json")

  # 1. Parse raw files into a dataframe
  if (verbose) {
    message("Parsing raw data")
  }
  # Add non-wear detection
  get_parsed_data = abase_noconvert$get_sleep$get_parsed_data
  out_data = get_parsed_data(
    raw_data_path, info_data_path,
    resample_hz = resample_hz,
    args = args)
  data = out_data[[0]]
  info = out_data[[1]]




  # 1.1 Transform data into a usable format for inference
  if (verbose) {
    message("Transforming data for model input")
  }
  transform_data2model_input = abase_noconvert$get_sleep$transform_data2model_input
  out_model  = transform_data2model_input(
    data2model_path, times_path, non_wear_path, data, args)
  data2model = out_model[[0]]
  times =  out_model[[1]]
  non_wear = out_model[[2]]

  if (verbose) {
    message(
      sprintf(
        "Data shape for data2model: %s",
        paste(data2model$shape, collapse = " x ")
      )
    )
    message(
      sprintf(
        "Data shape for times: %s",
        paste(times$shape, collapse = " x ")
      )
    )
    message(
      sprintf(
        "Data shape for nonwear: %s",
        paste(non_wear$shape, collapse = " x ")
      )
    )
  }

  # 1.2 Get the mean temperature and light (optional)
  out_temp = NULL
  if (reticulate::py_to_r(args$report_light_and_temp)) {
    if (verbose) {
      message("Calculating mean temperature and light")
    }
    mean_temp_and_light = abase_noconvert$get_sleep$mean_temp_and_light
    out_temp =  mean_temp_and_light(data)
    temp = out_temp[[0]]
    light = out_temp[[1]]
    if (verbose) {
      message(
        sprintf(
          "Data shape for temperature: %s",
          paste(data2model$shape, collapse = " x ")
        )
      )
      message(
        sprintf(
          "Data shape for light: %s",
          paste(light$shape, collapse = " x ")
        )
      )
    }
  }


  if (verbose) {
    message("Detecting sleep windows")
  }
  get_sleep_windows = abase_noconvert$get_sleep$get_sleep_windows
  out_windows = get_sleep_windows(data2model, times, non_wear, args)
  binary_y = out_windows[[0]]
  all_sleep_wins_df  = out_windows[[1]]
  sleep_wins_long_per_day_df = out_windows[[2]]
  master_acc = out_windows[[3]]
  master_npids = out_windows[[4]]

  master_npids = reticulate::py_to_r(master_npids)

  if (length(master_npids) <= 0) {
    msg = "No sleep windows >30 mins detected. Exiting..."
    message(msg)
    return(NULL)
  }
  start_sleep_net = abase_noconvert$get_sleep$start_sleep_net

  if (verbose) {
    message("Running SleepNet")
  }
  out_sleep = start_sleep_net(
    master_acc,
    master_npids,
    args$outdir,
    args$model_weight_path,
    local_repo_path = args$local_repo_path,
    device_id = args$pytorch_device
  )
  y_pred = out_sleep[[0]]
  test_pids = out_sleep[[1]]
  sleepnet_output = binary_y

  # 2. Map back SleepNet predictions to the original time series
  if (verbose) {
    message("Mapping SleepNet predictions back to original time series")
  }
  indices = seq(nrow(all_sleep_wins_df)) - 1L
  for (block_id in indices) {
    start_t = all_sleep_wins_df$start[[block_id]]
    end_t = all_sleep_wins_df$end[[block_id]]

    time_filter = (times >= start_t) & (times < end_t)

    # get the corresponding sleepnet predictions
    sleepnet_pred = y_pred[test_pids == block_id]

    # fill the sleepnet predictions back to the original dataframe
    sleepnet_output[time_filter] = sleepnet_pred
  }

  np = reticulate::import("numpy", convert = FALSE)
  SLEEPNET_BINARY_LABELS = abase_noconvert$macros$SLEEPNET_BINARY_LABELS
  SLEEPNET_LABELS = abase_noconvert$macros$SLEEPNET_LABELS
  SLEEPNET_THRE_CLASS_LABELS = abase_noconvert$macros$SLEEPNET_THRE_CLASS_LABELS


  # 3. Skip this step if predictions already exist
  # Output pandas dataframe
  # Times, Sleep/Wake, Sleep Stage
  if (verbose) {
    message("Generating predictions dataframe")
  }
  sleep_wake_predictions = np$vectorize(
    SLEEPNET_BINARY_LABELS$get)(sleepnet_output)
  sleep_stage_predictions = np$vectorize(
    SLEEPNET_THRE_CLASS_LABELS$get)(sleepnet_output)

  pd = reticulate::import("pandas", convert = FALSE)

  if (reticulate::py_to_r(args$report_light_and_temp)) {
    predictions_df = data.frame(
      time = reticulate::py_to_r(times),
      sleep_wake = reticulate::py_to_r(sleep_wake_predictions),
      sleep_stage = reticulate::py_to_r(sleep_stage_predictions),
      raw_label = reticulate::py_to_r(sleepnet_output),
      temperature = reticulate::py_to_r(temp),
      light = reticulate::py_to_r(light)
    )
  } else {
    predictions_df = data.frame(
      time = reticulate::py_to_r(times),
      sleep_wake = reticulate::py_to_r(sleep_wake_predictions),
      sleep_stage = reticulate::py_to_r(sleep_stage_predictions),
      raw_label = reticulate::py_to_r(sleepnet_output)
    )
  }

  # 4. Summary statistics
  # 4.1 Generate sleep block df and indicate the longest block per day
  # time start, time end, is_longest_block

  # all_sleep_wins_df['is_longest_block'] = FALSE
  # indices = seq(nrow(sleep_wins_long_per_day_df)) - 1L
  # for (irow in indices) {
  #   start_t = sleep_wins_long_per_day_df$start[[irow]]
  #   end_t = sleep_wins_long_per_day_df$end[[irow]]
  #   all_sleep_wins_df$is_longest_block[
  #     (all_sleep_wins_df$start == start_t) & (
  #       all_sleep_wins_df$end == end_t)] = TRUE
  # }
  if (verbose) {
    message("Generating sleep block df and indicate the longest block per day")
  }
  df_all_sleep_wins = reticulate::py_to_r(all_sleep_wins_df)
  df_sleep_wins_long_per_day = reticulate::py_to_r(sleep_wins_long_per_day_df)
  df_all_sleep_wins$is_longest_block = FALSE
  indices = seq(nrow(df_sleep_wins_long_per_day))
  for (irow in indices) {
    start_t = df_sleep_wins_long_per_day$start[[irow]]
    end_t = df_sleep_wins_long_per_day$end[[irow]]
    df_all_sleep_wins$is_longest_block[
      (df_all_sleep_wins$start == start_t) &
        (df_all_sleep_wins$end == end_t)] = TRUE
  }

  generate_sleep_parameters = abase_noconvert$summary$generate_sleep_parameters

  # 4.2  Generate daily summary statistics
  if (verbose) {
    message("Generating daily summary statistics")
  }
  # save day level df to csv
  # day_summary_df = generate_sleep_parameters(
  #   all_sleep_wins_df, times, predictions_df, day_summary_path)
  day_summary_df = generate_sleep_parameters(
    df_all_sleep_wins, times, predictions_df, day_summary_path)


  # 4.3 Generate summary statistics across different days
  py_summarize_daily_sleep = abase_noconvert$summary$summarize_daily_sleep
  py_summarize_daily_sleep(day_summary_df, output_json_path, args$min_wear)

  sdf = day_summary_df %>%
    reticulate::py_to_r() %>%
    dplyr::filter(wear_duration_H >= reticulate::py_to_r(args$min_wear))

  if (nrow(sdf) == 0) {
    summary_df = NULL
  } else {
    summary_df = summarize_daily_sleep(sdf)
  }
  # 5. Save outputs
  if (verbose) {
    message("Creating outputs")
  }
  paths = list(
    raw_data_path = raw_data_path,
    info_data_path = info_data_path,
    data2model_path = data2model_path,
    times_path = times_path,
    non_wear_path = non_wear_path,
    day_summary_path = day_summary_path,
    output_json_path = output_json_path
  )
  result = list(
    predictions = predictions_df,
    sleep_windows = df_all_sleep_wins,
    sleep_windows_long = df_sleep_wins_long_per_day,
    day_summary = day_summary_df,
    summary = summary_df,
    # summary_json = output_json_path,
    paths = paths,
    output_data = out_data,
    output_model = out_model,
    output_windows = out_windows,
    output_sleep = out_sleep
  )
  result$output_temperature = out_temp

  result = lapply(result, reticulate::py_to_r)
  result
}



read_summary_json = function(output_json_path) {
  funcs <- reticulate::import_builtins()

  # Open the file and load the JSON data
  js = reticulate::import("json")
  fl <- funcs$open(output_json_path, "r")
  list_summarize_daily_sleep <- js$load(fl)
  fl$close()

  df_summarize_daily_sleep = data.frame(
    metric = names(list_summarize_daily_sleep),
    value = unlist(list_summarize_daily_sleep)
  )
  rownames(df_summarize_daily_sleep) = NULL

}
