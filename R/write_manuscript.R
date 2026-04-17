#' Export a ggplot in publication-ready format
#'
#' Writes a ggplot2 object to PDF/SVG/PNG/TIFF/EPS at the specified
#' physical dimensions (in millimetres) and resolution.
#'
#' @param plot A ggplot2 object.
#' @param filename Character. Output path (extension determines format).
#' @param width_mm Numeric. Width in mm. `174` = Springer single-column,
#'   `88` = double-column. Default `174`.
#' @param height_mm Numeric. Height in mm. Default `120`.
#' @param dpi Integer. Raster resolution. Default `300`.
#' @return Invisibly, the filename.
#' @export
#' @examples
#' \dontrun{
#' p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, hp)) +
#'   ggplot2::geom_point()
#' export_figure(p, "mtcars.pdf", width_mm = 120, height_mm = 90)
#' }
export_figure <- function(plot,
                          filename,
                          width_mm  = 174,
                          height_mm = 120,
                          dpi       = 300) {

  fmt <- tolower(tools::file_ext(filename))
  if (!fmt %in% c("pdf", "svg", "png", "tiff", "eps"))
    cli::cli_abort("Unknown format: {.val {fmt}}")

  ggplot2::ggsave(
    filename = filename,
    plot     = plot,
    width    = width_mm  / 25.4,
    height   = height_mm / 25.4,
    dpi      = dpi,
    device   = fmt
  )

  cli::cli_alert_success(
    "Figure saved: {.path {filename}} ({width_mm}x{height_mm} mm)"
  )
  invisible(filename)
}

#' Export a tibble as a Springer Nature compatible LaTeX table
#'
#' Produces a `booktabs`-style table with the sn-jnl.cls requirement of
#' using `\\botrule` instead of `\\bottomrule` and escaping `<`/`>` in
#' cells. Optionally appends a `tablenotes` footnote.
#'
#' @param data A tibble/data.frame.
#' @param filename Character. Output `.tex` path.
#' @param caption Character. Table caption.
#' @param label Character. LaTeX label (without the `tab:` prefix; it
#'   will be added).
#' @param note Character. Optional footnote text.
#' @param digits Integer. Digits for numeric columns. Default `3`.
#' @param col_format Character vector. Column alignment spec
#'   (e.g. `c("l", "r", "r")`). Default `NULL` picks `"l"` for the
#'   first column and `"r"` for the rest.
#' @return The LaTeX source, invisibly.
#' @export
#' @examples
#' \dontrun{
#' export_latex_table(head(iris), "iris.tex",
#'                    caption = "First rows of iris.",
#'                    label   = "iris")
#' }
export_latex_table <- function(data,
                               filename,
                               caption,
                               label,
                               note       = NULL,
                               digits     = 3,
                               col_format = NULL) {

  if (!requireNamespace("xtable", quietly = TRUE))
    cli::cli_abort(
      "Package {.pkg xtable} required. ",
      "Install with {.code install.packages('xtable')}."
    )

  # Escape <,> in character cells
  data <- dplyr::mutate(
    data,
    dplyr::across(
      dplyr::where(is.character),
      ~ .escape_latex_math(.x)
    )
  )

  n_col <- ncol(data)
  if (is.null(col_format))
    col_format <- c("l", rep("r", max(0, n_col - 1)))

  tab <- xtable::xtable(
    data,
    caption = caption,
    label   = paste0("tab:", label),
    digits  = digits,
    align   = c("l", col_format)
  )

  tex_str <- xtable::print.xtable(
    tab,
    booktabs         = TRUE,
    include.rownames = FALSE,
    print.results    = FALSE,
    comment          = FALSE
  )

  tex_str <- .sn_replace_bottomrule(tex_str)

  if (!is.null(note)) {
    footnote_tex <- paste0(
      "\\begin{tablenotes}\n",
      "\\item ", note, "\n",
      "\\end{tablenotes}\n"
    )
    tex_str <- sub(
      "\\\\end\\{tabular\\}",
      paste0("\\\\end{tabular}\n", footnote_tex),
      tex_str
    )
  }

  writeLines(tex_str, filename)
  cli::cli_alert_success("LaTeX table: {.path {filename}}")
  invisible(tex_str)
}

#' Fill `[XX_*]` placeholders in a LaTeX manuscript
#'
#' Substitutes `[XX_*]` placeholders in a LaTeX source file with
#' automatically computed simulation statistics. The mapping from
#' placeholder to computation is assembled inside this function from
#' [doctrine_effect()], [al_efficiency()] and [compute_ihl_index()].
#'
#' @param sim_data A `dynasimR_data` object.
#' @param tex_file Character. Path to the LaTeX source file.
#' @param output_file Character. Output path; default appends
#'   `_filled` before `.tex`.
#' @param dry_run Logical. If `TRUE`, print replacements but do not
#'   write a file. Default `FALSE`.
#' @param muf_scenario Character. MUF scenario ID. Default `"M-S08"`.
#' @param milnec_scenario Character. MilNec scenario ID.
#'   Default `"M-S07"`.
#' @param baseline_scenario Character. Baseline scenario ID.
#'   Default `"M-S00"`.
#' @return Named character vector of the replacements (invisibly).
#' @export
fill_placeholders <- function(sim_data,
                              tex_file,
                              output_file        = NULL,
                              dry_run            = FALSE,
                              muf_scenario       = "M-S08",
                              milnec_scenario    = "M-S07",
                              baseline_scenario  = "M-S00") {

  if (!file.exists(tex_file))
    cli::cli_abort("File not found: {.path {tex_file}}")

  doc <- try(doctrine_effect(
    sim_data,
    muf_scenario    = muf_scenario,
    milnec_scenario = milnec_scenario
  ), silent = TRUE)
  al  <- try(al_efficiency(sim_data), silent = TRUE)
  ihl <- try(compute_ihl_index(sim_data, by_identity = FALSE),
             silent = TRUE)

  get_num <- function(tbl, filter_expr, column) {
    if (inherits(tbl, "try-error")) return(NA_real_)
    subs <- dplyr::filter(tbl, !!rlang::parse_expr(filter_expr))
    if (nrow(subs) == 0) return(NA_real_)
    as.numeric(subs[[column]][1])
  }

  s <- sim_data$summary

  replacements <- c(
    "[XX_DOCTRINE_DELTA_KIA]"   =
      if (inherits(doc, "try-error")) "NA" else
        as.character(round(abs(
          doc$delta_kia$median_pct_points[
            doc$delta_kia$identity == "all"][1]), 1)),
    "[XX_DOCTRINE_DELTA_CI_LO]" =
      if (inherits(doc, "try-error")) "NA" else
        as.character(round(
          doc$delta_kia$ci_lo[doc$delta_kia$identity == "all"][1], 1)),
    "[XX_DOCTRINE_DELTA_CI_HI]" =
      if (inherits(doc, "try-error")) "NA" else
        as.character(round(
          doc$delta_kia$ci_hi[doc$delta_kia$identity == "all"][1], 1)),
    "[XX_IHL_MUF]" =
      as.character(round(get_num(ihl,
        glue::glue("scenario == '{muf_scenario}'"),  "ici"), 3)),
    "[XX_IHL_MILNEC]" =
      as.character(round(get_num(ihl,
        glue::glue("scenario == '{milnec_scenario}'"), "ici"), 3)),
    "[XX_OPTIMAL_AL]" =
      if (inherits(al, "try-error")) "NA" else
        as.character(al$optimal_al),
    "[XX_KIA_BASELINE]" = as.character(round(
      stats::median(s$kia_rate[s$scenario == baseline_scenario],
                    na.rm = TRUE) * 100, 1)),
    "[XX_KIA_BEST]" = as.character(round(
      min(tapply(s$kia_rate, s$scenario,
                 stats::median, na.rm = TRUE), na.rm = TRUE) * 100,
      1))
  )

  cli::cli_h2("Placeholder substitutions")
  purrr::walk2(
    names(replacements), replacements,
    ~ cli::cli_bullets(c("*" = "{.code {.x}} -> {.val {.y}}"))
  )

  if (dry_run) {
    cli::cli_alert_info("Dry run: no file written.")
    return(invisible(replacements))
  }

  tex <- readLines(tex_file)
  for (i in seq_along(replacements))
    tex <- gsub(names(replacements)[i],
                replacements[i], tex, fixed = TRUE)

  if (is.null(output_file))
    output_file <- sub("\\.tex$", "_filled.tex", tex_file)

  writeLines(tex, output_file)
  cli::cli_alert_success("Filled: {.path {output_file}}")
  invisible(replacements)
}
