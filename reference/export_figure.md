# Export a ggplot in publication-ready format

Writes a ggplot2 object to PDF/SVG/PNG/TIFF/EPS at the specified
physical dimensions (in millimetres) and resolution.

## Usage

``` r
export_figure(plot, filename, width_mm = 174, height_mm = 120, dpi = 300)
```

## Arguments

- plot:

  A ggplot2 object.

- filename:

  Character. Output path (extension determines format).

- width_mm:

  Numeric. Width in mm. `174` = Springer single-column, `88` =
  double-column. Default `174`.

- height_mm:

  Numeric. Height in mm. Default `120`.

- dpi:

  Integer. Raster resolution. Default `300`.

## Value

Invisibly, the filename.

## Examples

``` r
if (FALSE) { # \dontrun{
p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, hp)) +
  ggplot2::geom_point()
export_figure(p, "mtcars.pdf", width_mm = 120, height_mm = 90)
} # }
```
