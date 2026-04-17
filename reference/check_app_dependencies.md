# Check availability of Shiny-app dependencies

Inspects the `Suggests:` packages required by the embedded Shiny
dashboard and prints a summary of which ones are installed.

## Usage

``` r
check_app_dependencies()
```

## Value

A tibble with columns `package`, `installed`, `version`, invisibly.
