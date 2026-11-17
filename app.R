# Interactive version of the HG002 chr20 benchmark.
# Run from the repo root: Rscript -e 'shiny::runApp()'
# Needs shiny and ggplot2: install.packages(c("shiny", "ggplot2"))

library(shiny)
library(ggplot2)

# Benchmark numbers from the GIAB HG002 chromosome 20 run (NovaSeq PCR-free
# 35x, 9.4M read pairs, truth = NISTv4.2.1 confident regions, RTG vcfeval).
# The full write-up is in PR #1.
benchmark <- data.frame(
    call_set = rep(c("Unfiltered", "Hard filters"), each = 3),
    type = factor(rep(c("SNP", "Indel", "All"), 2), levels = c("SNP", "Indel", "All")),
    tp = as.integer(c(70936, 11099, 82035, 70581, 11099, 81680)),
    fp = as.integer(c(923, 113, 1036, 498, 101, 599)),
    fn = as.integer(c(426, 128, 554, 781, 128, 909)),
    precision = c(0.9872, 0.9899, 0.9875, 0.9930, 0.9910, 0.9927),
    recall = c(0.9940, 0.9886, 0.9933, 0.9891, 0.9886, 0.9890),
    f1 = c(0.9906, 0.9893, 0.9904, 0.9910, 0.9898, 0.9909)
)

steps <- data.frame(
    step = c("BWA-MEM", "MarkDuplicates", "BaseRecalibrator", "ApplyBQSR",
             "HaplotypeCaller", "MultiQC"),
    what = c("align reads + read groups, sorted BAM",
             "flag PCR and optical duplicates",
             "BQSR model from known sites",
             "recalibrated base qualities",
             "gVCF per sample (-ERC GVCF)",
             "duplication metrics report")
)

ui <- fluidPage(
    titlePanel("GATK4 germline pipeline, HG002 chr20 benchmark"),
    p("Nextflow DSL2, one module per tool, every step in Docker. BWA 0.7.19,",
      "GATK 4.6.2.0, Nextflow 26.04.6, run on 2 CPUs with 7 GB RAM."),
    h4("F1 by variant type and call set"),
    plotOutput("f1", height = "340px"),
    p("Hard filters are the GATK-recommended thresholds applied outside the",
      "pipeline. They trade a little recall for cleaner precision."),
    h4("Full benchmark table"),
    tableOutput("bench_table"),
    h4("Pipeline steps"),
    tableOutput("steps")
)

server <- function(input, output) {
    output$f1 <- renderPlot({
        ggplot(benchmark, aes(x = type, y = f1, fill = call_set)) +
            geom_col(position = position_dodge(0.7), width = 0.6) +
            coord_cartesian(ylim = c(0.985, 0.993)) +
            scale_fill_manual(values = c("Unfiltered" = "#4C72B0",
                                         "Hard filters" = "#d6604d")) +
            labs(x = NULL, y = "F1", fill = NULL) +
            theme_minimal(base_size = 13) +
            theme(legend.position = "top")
    })

    output$bench_table <- renderTable({
        d <- benchmark[, c("call_set", "type", "tp", "fp", "fn",
                           "precision", "recall", "f1")]
        # format everything as character so renderTable does not re-round it
        d$tp <- format(d$tp, big.mark = ",")
        d$fp <- format(d$fp, big.mark = ",")
        d$fn <- format(d$fn, big.mark = ",")
        d$precision <- sprintf("%.4f", d$precision)
        d$recall <- sprintf("%.4f", d$recall)
        d$f1 <- sprintf("%.4f", d$f1)
        names(d) <- c("call set", "type", "TP", "FP", "FN",
                      "precision", "recall", "F1")
        d
    }, rownames = FALSE)

    output$steps <- renderTable(steps, rownames = FALSE)
}

shinyApp(ui, server)
