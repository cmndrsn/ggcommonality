#' Title
#' @noRd
#' @param data.boot
#' @param formula
#' @param data
#' @param include_total
#' @param ci_bounds
#'
#' @returns
#'
#' @examples
.ci_plot_coordinates <- function(
    data.boot,
    formula,
    data,
    include_total = TRUE,
    ci_bounds = c(.025, .975)
) {
  coef <- yhat::regr(
    lm(
      formula = formula,
      data = data
    )
  )$Commonality_Data$CC


  coef <- as.data.frame(coef)
  coef <- tibble::rownames_to_column(as.data.frame(coef), var = "var")
  names(coef) <- c("var", "cc", "cc_pct")
  bs_ci <- apply(
    data.boot,
    1,
    FUN = function(x) {
      quantile(x,
               ci_bounds
      )

    }


  )



  bs_ci <- t(bs_ci) |>
    as.data.frame() |>
    tibble::rownames_to_column()
  names(bs_ci) <- c("var", "lci", "uci")

  bs_ci <- merge(bs_ci, coef)

  bs_ci$var <- bs_ci$var |>
    stringr::str_remove_all("Common to |Unique to | and | ")

  bs_ci$com <- bs_ci$var

  bs_ci <- bs_ci |>
    tidyr::separate_longer_delim(
      cols = "var",
      delim = ","
    )
  bs_ci <- bs_ci |>
    group_by(com) |>
    # first sort so we can plot colours in alphabetical order
    mutate(
           count = as.numeric(factor(var))
           )
  bs_ci$var <- factor(bs_ci$var, levels = (unique(bs_ci$var)))

  # define length of each line based on which position it is in the CA
  #bs_ci$xmax <- bs_ci$lci + ((bs_ci$uci-bs_ci$lci)/bs_ci$count)

  bs_ci$order <- stringr::str_count(bs_ci$com, ",")+1
  xmin_lvls <- unique(bs_ci$com[order(bs_ci$order)])
  bs_ci$xmin <-as.numeric(factor(bs_ci$com, levels = xmin_lvls))
  bs_ci$start_pos <- bs_ci$xmin - 0.45
  bs_ci$end_pos <- bs_ci$xmin + 0.45
  bs_ci$end_pos <- bs_ci$start_pos +
    bs_ci$count * ((bs_ci$end_pos-bs_ci$start_pos)/bs_ci$order)


  bs_ci <- bs_ci |>
    group_by(com) |>
    mutate(outline_ymin = min(lci),
           outline_ymax = max(uci),
           outline_xmin = min(start_pos),
           outline_xmax = max(end_pos))


  bs_ci <- bs_ci[order(bs_ci$order),]
  bs_ci <- bs_ci |>
    group_by(com) |>
    mutate(end_pos = rev(end_pos))

  bs_ci$com <- factor(bs_ci$com, levels = unique(bs_ci$com))
  bs_ci <- bs_ci |>
    group_by(com) |>
    mutate(
      end_pos = sort(
        end_pos,
        decreasing = TRUE)
      )

  if(!include_total) {
    bs_ci <- bs_ci |> dplyr::filter(com != "Total")
  }

  return(bs_ci)

}

#' Title
#' @noRd
#' @param df
#' @param t
#' @param s
#'
#' @returns
#'
#' @examples
.com_errorbox <- function(df, t = NULL,s = NULL) {
  df |>
    ggplot(
      aes(x = xmin, xmin = xmin, y = cc,
          ymin = lci, ymax = uci)) +
    geom_rect(aes(xmin=outline_xmin,
                  xmax = outline_xmax,
                  ymin = outline_ymin,
                  ymax = outline_ymax),
              colour = "black", size = 1.25)+
    geom_rect(aes(xmin=start_pos, xmax = end_pos, fill = var))+
    geom_point(colour = "black")+
    scale_x_continuous(breaks = df$xmin, labels = factor(df$com, levels = unique(df$com)))+
    ggtitle(t,s)
}

#' Title
#' @noRd
#' @param df
#'
#' @returns
#'
#' @examples
.plot_com_unstacked <- function(df) {
  df |>
    ggplot(
      aes(x = xmin, xmin = xmin, y = cc,
          ymin = 0, ymax = cc)) +
    geom_rect(aes(xmin=outline_xmin,
                  xmax = outline_xmax,
                  ymin = 0,
                  ymax = cc),
              colour = "black", size = 1.25)+
    geom_rect(aes(xmin=start_pos, xmax = end_pos, fill = var))+
    scale_x_continuous(breaks = df$xmin, labels = factor(df$com, levels = unique(df$com)))
}


#' Title
#' @noRd
#' @param df
#' @param ...
#'
#' @returns
#'
#' @examples
.com_unstacked_errorbar <- function(df, ...) {
    geom_errorbar(data = df, aes(ymin = lci, ymax = uci), ...)
}

