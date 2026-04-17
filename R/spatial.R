#' Supply-Demand Index (SDI) per region (REHASIM)
#'
#' Computes a per-region Supply-Demand Index: the ratio of available
#' rehabilitation capacity to demand. Values > 1 indicate oversupply,
#' values < 1 undersupply.
#'
#' @param data A `dynasimR_data` object or summary tibble with
#'   `region`, `supply` and `demand` columns.
#' @param region_col Character. Region column name. Default `"region"`.
#' @param supply_col Character. Supply column name. Default `"supply"`.
#' @param demand_col Character. Demand column name. Default `"demand"`.
#' @param eps Numeric. Offset to avoid division by zero. Default `1`.
#'
#' @return A tibble with columns `region`, `supply_median`,
#'   `demand_median`, `sdi_median`, `sdi_q025`, `sdi_q975`,
#'   `undersupply`.
#' @export
spatial_supply_demand <- function(data,
                                  region_col = "region",
                                  supply_col = "supply",
                                  demand_col = "demand",
                                  eps        = 1) {

  d <- if (inherits(data, "dynasimR_data")) data$summary else data
  .require_cols(d, c(region_col, supply_col, demand_col),
                where = "summary")

  d |>
    dplyr::group_by(dplyr::across(dplyr::all_of(region_col))) |>
    dplyr::summarise(
      supply_median = stats::median(.data[[supply_col]], na.rm = TRUE),
      demand_median = stats::median(.data[[demand_col]], na.rm = TRUE),
      sdi_median    = stats::median(
        .data[[supply_col]] / (.data[[demand_col]] + eps),
        na.rm = TRUE),
      sdi_q025      = stats::quantile(
        .data[[supply_col]] / (.data[[demand_col]] + eps),
        0.025, na.rm = TRUE, names = FALSE),
      sdi_q975      = stats::quantile(
        .data[[supply_col]] / (.data[[demand_col]] + eps),
        0.975, na.rm = TRUE, names = FALSE),
      .groups       = "drop"
    ) |>
    dplyr::mutate(undersupply = .data$sdi_median < 1)
}
