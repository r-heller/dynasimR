## End-to-end smoke test
suppressPackageStartupMessages(devtools::load_all(quiet = TRUE))

sim <- load_example_data()
cat("Loaded:", sim$load_info$simulation_type, "\n")

km <- km_estimate(sim, endpoint = "role2")
cat("KM OK, log-rank p =",
    round(km$logrank$p_value, 4), "\n")

cx <- cox_model(sim, endpoint = "role2",
                reference_scenario = "M-S00")
cat("Cox OK, N HR terms =", nrow(cx$forest_data), "\n")

doc <- doctrine_effect(sim, muf_scenario = "M-S08",
                       milnec_scenario = "M-S07",
                       n_bootstrap = 200)
cat("Doctrine OK, narrative len =",
    nchar(doc$narrative), "\n")

al <- al_efficiency(sim,
        al_scenarios = c("0" = "M-S00", "1" = "M-S01"),
        n_bootstrap  = 100)
cat("AL OK, optimal =", al$optimal_al, "\n")

ihl <- compute_ihl_index(sim, by_identity = FALSE,
                         n_bootstrap = 100)
cat("IHL OK, scenarios =", nrow(ihl), "\n")

cat("Plot classes: ")
cat(class(plot_km(km))[1], "/")
cat(class(plot_forest(cx))[1], "/")
cat(class(plot_al_tradeoff(al))[1], "/")
cat(class(plot_doctrine(doc))[1], "/")
cat(class(plot_scenario_heatmap(sim))[1], "\n")
cat("ALL GOOD.\n")
