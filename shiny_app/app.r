################################################################################
#                                                                              #
#   DAPHNE trophic interaction network                                        #
#                                                                              #
#   For a selected crop, shows its main pests, their natural enemies and the   #
#   hyperparasitoids of those enemies as an interactive network. Clicking an   #
#   edge lists the abstracts that provide the evidence for that interaction.   #
#                                                                              #
#   Data files are built from DAPHNE.rds by prepare_data.r.                    #
#                                                                              #
#   Hosted at https://ddx5w5-daan-scheepens.shinyapps.io/daphne-interaction-network/
#   Deploy (from the parent folder):
#     rsconnect::deployApp("shiny_app/", appName = "daphne-interaction-network", forceUpdate = TRUE)
#   Logs: rsconnect::showLogs("shiny_app/", appName = "daphne-interaction-network")
#                                                                              #
################################################################################

library(shiny)
library(visNetwork)
library(DT)
library(dplyr)
library(purrr)

enemy_edges <- readRDS("enemy_edges.rds") # all natural-enemy interactions
crops       <- readRDS("crops.rds")       # crop names and FAO groups

edge_colours <- c(Herbivory = "green", Predation = "red", Parasitism = "blue", Hyperparasitism = "purple")

# Number of distinct abstracts per species in column `col`
n_abstracts_by <- function(records, col) {
  records %>%
    group_by(id = {{ col }}) %>%
    summarise(n = n_distinct(EID, na.rm = TRUE), .groups = "drop")
}

# Edge widths from 1 to `max_width`, scaled with log(number of abstracts)
scale_width <- function(n, max_width) {
  x <- log(n + 1)
  if (max(x) == min(x)) return(rep(2, length(n)))
  1 + (x - min(x)) / (max(x) - min(x)) * (max_width - 1)
}

# Wrap long text in a scrollable box (text is HTML-escaped)
scroll_box <- function(x) {
  ifelse(is.na(x) | x == "", "", paste0("<div class='scroll-box'>", htmltools::htmlEscape(x), "</div>"))
}



################################################################################
#                                     UI                                       #
################################################################################

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      .overview-card {
        background-color: #f8f9fa;
        border-left: 4px solid #337ab7;
        padding: 12px;
        margin-bottom: 15px;
        border-radius: 4px;
        line-height: 1.6;
      }
      .scroll-box {
        max-height: 100px;
        min-width: 300px;
        max-width: 450px;
        overflow-y: auto;
        overflow-x: hidden;
        white-space: normal;
        background-color: #fafafa;
        border: 1px solid #e5e5e5;
        padding: 6px;
        border-radius: 4px;
      }
    "))
  ),

  titlePanel("DAPHNE Trophic Interaction Network"),

  fluidRow(
    # --- Controls ---
    column(width = 3,
           wellPanel(
             selectInput("selected_crop", "Select Crop:",
                         choices = split(crops$crop_name, factor(crops$crop_group, levels = unique(crops$crop_group))),
                         selected = "wheat"),

             helpText("Diamond = crop, circle = herbivore, square = natural enemy, triangle = hyperparasitoid.",
                      "Edges: green = herbivory, red = predation, blue = parasitism, purple = hyperparasitism."),

             sliderInput("max_pests", "Number of Top Pests:",
                         min = 0, max = 100, value = 10, step = 1),

             sliderInput("enemies_per_pest", "Max Enemies per Pest:",
                         min = 0, max = 100, value = 10, step = 1),

             sliderInput("min_n_major", "(Optional) How many abstracts evidencing 'major' pest importance are required for a herbivore to qualify as pest:",
                         min = 0, max = 100, value = 1, step = 1),

             sliderInput("min_n_important", "(Optional) How many abstracts evidencing 'important natural enemy' are required for a species to qualify as natural enemy of a pest:",
                         min = 0, max = 100, value = 1, step = 1),

             sliderInput("max_edge_width", "Max Edge Width (scales logarithmically with the number of abstracts):",
                         min = 1, max = 6, value = 6, step = 1)
           )
    ),

    # --- Network and downloads ---
    column(width = 9,
           visNetworkOutput("network", height = "75vh"),
           br(),
           fluidRow(
             column(width = 6,
                    downloadButton("download_html", "Save Network as HTML",
                                   class = "btn-primary", style = "width: 100%; font-weight: bold;")
             ),
             column(width = 6,
                    downloadButton("download_rds", "Save Filtered Data (.rds)",
                                   class = "btn-success", style = "width: 100%; font-weight: bold;")
             )
           )
    )
  ),

  hr(),

  # --- Evidence for the selected edge ---
  fluidRow(
    column(width = 12,
           h4("Edge Details Summary"),
           uiOutput("edge_overview_metadata"),
           br(),
           DTOutput("edge_details")
    )
  )
)



################################################################################
#                                   Server                                     #
################################################################################

server <- function(input, output, session) {

  # Herbivore interactions on the selected crop (only re-read when the crop changes)
  crop_herbivory <- reactive({
    readRDS(paste0("herbivore_edges_", input$selected_crop, ".rds"))
  })


  # --- Network for the current crop and filter settings ---
  network_data <- reactive({
    crop <- input$selected_crop
    herbivore_edges <- crop_herbivory()

    # 1. Pests: herbivores with enough 'major pest' abstracts, ranked by major, then pest abstracts
    crop_pests <- herbivore_edges %>%
      group_by(Subject) %>%
      summarise(nPest  = n_distinct(EID[Pest %in% TRUE]),
                nMajor = n_distinct(EID[Pest.Importance %in% "major"]),
                .groups = "drop") %>%
      filter(nMajor >= input$min_n_major) %>%
      slice_max(order_by = tibble(nMajor, nPest), n = input$max_pests, with_ties = TRUE) %>%
      pull(Subject)

    # 2. Natural enemies: for each pest, the enemies with enough 'important enemy' abstracts
    crop_enemies <- enemy_edges %>%
      filter(Object %in% crop_pests) %>%
      group_by(Subject, Object) %>%
      summarise(nEID            = n_distinct(EID),
                nImportantEnemy = n_distinct(EID[Important.Enemy %in% TRUE]),
                .groups = "drop") %>%
      filter(nImportantEnemy >= input$min_n_important) %>%
      group_by(Object) %>%
      slice_max(order_by = tibble(nImportantEnemy, nEID), n = input$enemies_per_pest, with_ties = TRUE) %>%
      ungroup() %>%
      pull(Subject) %>%
      unique()

    species <- c(crop_pests, crop_enemies)

    # 3. Interactions between these species (herbivory points to the crop itself)
    interactions <- bind_rows(
      herbivore_edges %>%
        filter(Subject %in% species) %>%
        mutate(Label = "Herbivory", Object = crop),
      enemy_edges %>%
        filter(Feeding.Mode %in% c("predation", "parasitism"), Subject %in% species, Object %in% species) %>%
        mutate(Label = if_else(Feeding.Mode == "predation", "Predation", "Parasitism")),
      enemy_edges %>%
        filter(Feeding.Mode %in% "hyperparasitism", Object %in% crop_enemies) %>%
        mutate(Label = "Hyperparasitism")
    ) %>%
      filter(!is.na(Subject), Subject != "")

    validate(need(nrow(interactions) > 0, "No interactions for this crop with the current filters."))

    # One row per record, with the columns shown in the app and saved by the .rds download
    records <- interactions %>%
      transmute(
        from = Subject, to = Object, label = Label,
        `Subject Verbatim` = Subject.Verbatim, `Object Verbatim` = Object.Verbatim,
        `Feeding Mode` = Feeding.Mode, Pest, `Pest Importance` = Pest.Importance,
        `Important Enemy` = Important.Enemy, Biocontrol,
        `Invasive In` = map_chr(InvasiveIn, ~ paste(.x, collapse = ", ")),
        Vectors       = map_chr(Vectors, ~ paste(.x, collapse = ", ")),
        EID, Abstract, `Generated Response` = Generated.Response,
        Subject.Phylum, Subject.Class, Subject.Order, Subject.Family,
        Object.Phylum, Object.Class, Object.Order, Object.Family,
        Title, Year, `Source title`, DOI, Link, `Author Keywords`, `Index Keywords`
      )

    # 4. Edges: one per species pair, coloured by (the first) interaction type
    edges <- records %>%
      group_by(from, to) %>%
      summarise(label       = paste(unique(label), collapse = " & "),
                n_abstracts = n_distinct(EID, na.rm = TRUE),
                .groups = "drop") %>%
      mutate(id    = paste0(from, "->", to),
             color = unname(edge_colours[sub(" & .*", "", label)]),
             title = paste0(label, ": ", n_abstracts, " abstract(s)"),
             width = scale_width(n_abstracts, input$max_edge_width))

    # 5. Nodes: shape by role, from the number of abstracts as herbivore vs as natural enemy
    herb_n  <- n_abstracts_by(filter(records, label == "Herbivory"), from) %>% rename(n_herb = n)
    enemy_n <- n_abstracts_by(filter(records, label %in% c("Predation", "Parasitism")), from) %>% rename(n_enemy = n)
    total_n <- n_abstracts_by(bind_rows(select(records, from, EID), select(records, from = to, EID)), from) %>% rename(n_total = n)
    hyperparasitoids <- unique(records$from[records$label == "Hyperparasitism"])

    nodes <- tibble(id = unique(c(edges$from, edges$to))) %>%
      left_join(herb_n, by = "id") %>%
      left_join(enemy_n, by = "id") %>%
      left_join(total_n, by = "id") %>%
      mutate(n_herb  = coalesce(n_herb, 0L),
             n_enemy = coalesce(n_enemy, 0L),
             label   = id,
             title   = paste0("<strong>", htmltools::htmlEscape(id), "</strong><br/>Abstracts: ", n_total),
             shape   = case_when(id == crop                          ~ "diamond",
                                 id %in% hyperparasitoids            ~ "triangle",
                                 n_enemy > 0 & n_enemy >= n_herb     ~ "square",
                                 TRUE                                ~ "dot"),
             color   = if_else(id == crop, "#2ca02c", NA_character_)) %>%
      select(id, label, title, shape, color)

    list(nodes = nodes, edges = edges, records = records)
  })


  # --- Network plot ---
  output$network <- renderVisNetwork({
    data <- network_data()

    visNetwork(data$nodes, data$edges) %>%
      visEdges(arrows = "to") %>%
      visNodes(size = 20) %>%
      visPhysics(solver = "forceAtlas2Based", stabilization = TRUE) %>%
      # clicking an edge sets input$clicked_edge_id; clicking a node or the background clears it
      visEvents(click = "function(params) {
                  var edge = (params.nodes.length === 0 && params.edges.length === 1) ? params.edges[0] : null;
                  Shiny.setInputValue('clicked_edge_id', edge);
                }") %>%
      visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE)
  })


  # --- Records behind the clicked edge (NULL if no edge is selected) ---
  selected_records <- reactive({
    sel <- input$clicked_edge_id
    if (is.null(sel)) return(NULL)
    data <- network_data()
    edge <- filter(data$edges, id == sel)
    if (nrow(edge) == 0) return(NULL)
    filter(data$records, from == edge$from, to == edge$to)
  })


  # --- Summary card for the clicked edge ---
  output$edge_overview_metadata <- renderUI({
    records <- selected_records()
    if (is.null(records)) return(div(class = "overview-card", "Select an edge to see the evidence."))

    r <- records[1, ]
    # name followed by the available higher taxonomy, e.g. "Aphis fabae (Arthropoda, Insecta, Hemiptera, Aphididae)"
    with_taxonomy <- function(name, ranks) {
      ranks <- ranks[!is.na(ranks) & ranks != ""]
      if (length(ranks) == 0) name else paste0(name, " (", paste(ranks, collapse = ", "), ")")
    }
    labels <- unique(records$label)

    lines <- list(
      tags$strong("Interaction type: "), paste(labels, collapse = " & "), br(),
      tags$strong("Subject: "), with_taxonomy(r$from, c(r$Subject.Phylum, r$Subject.Class, r$Subject.Order, r$Subject.Family)), br(),
      tags$strong("Object: "),  with_taxonomy(r$to,   c(r$Object.Phylum,  r$Object.Class,  r$Object.Order,  r$Object.Family)),  br(),
      tags$strong("Records: "), sprintf("%d, from %d abstract(s)", nrow(records), n_distinct(records$EID))
    )
    if ("Herbivory" %in% labels) {
      lines <- c(lines, list(br(), tags$strong("Herbivory: "),
                             sprintf("Pest (%d) | Major importance (%d) | Minor importance (%d)",
                                     sum(records$Pest %in% TRUE),
                                     sum(records$`Pest Importance` %in% "major"),
                                     sum(records$`Pest Importance` %in% "minor"))))
    }
    if (any(c("Predation", "Parasitism") %in% labels)) {
      lines <- c(lines, list(br(), tags$strong("Natural enemy: "),
                             sprintf("Important enemy (%d) | Biocontrol (%d)",
                                     sum(records$`Important Enemy` %in% TRUE),
                                     sum(records$Biocontrol %in% TRUE))))
    }
    div(class = "overview-card", lines)
  })


  # --- Table of records for the clicked edge ---
  output$edge_details <- renderDT({
    records <- selected_records()
    if (is.null(records)) {
      return(datatable(data.frame(Status = "Select an edge to see the evidence."), options = list(dom = "t"), rownames = FALSE))
    }

    # pest columns for herbivory edges, enemy columns for predation/parasitism edges
    labels <- unique(records$label)
    cols <- c("Subject Verbatim", "Object Verbatim",
              if (identical(labels, "Herbivory")) c("Feeding Mode", "Pest", "Pest Importance"),
              if (all(labels %in% c("Predation", "Parasitism"))) c("Important Enemy", "Biocontrol"),
              "Invasive In", "Vectors", "EID", "Title", "Abstract", "Generated Response",
              "Year", "Source title", "DOI", "Link", "Author Keywords", "Index Keywords")
    long_text <- c("Abstract", "Generated Response", "Author Keywords", "Index Keywords")

    details <- records %>%
      select(all_of(cols)) %>%
      mutate(across(all_of(long_text), scroll_box))

    # long-text columns are already escaped inside their boxes; escape all others
    datatable(details, rownames = FALSE, escape = setdiff(cols, long_text),
              options = list(pageLength = 10, scrollX = TRUE, autoWidth = FALSE))
  })


  # --- Download: interactive network as a standalone HTML page ---
  output$download_html <- downloadHandler(
    filename = function() paste0("network-", input$selected_crop, "-", Sys.Date(), ".html"),
    content = function(file) {
      data <- network_data()
      net <- visNetwork(data$nodes, data$edges, width = "100%", height = "90vh") %>%
        visEdges(arrows = "to") %>%
        visNodes(size = 24, font = list(size = 18, strokeWidth = 4, strokeColor = "#ffffff")) %>%
        visPhysics(solver = "forceAtlas2Based", stabilization = list(iterations = 200, fit = TRUE)) %>%
        visEvents(stabilized = "function() { this.fit(); }") %>%
        visInteraction(hover = TRUE, navigationButtons = TRUE)
      visSave(net, file = file, selfcontained = TRUE)
    }
  )

  # --- Download: records of the current network as .rds ---
  output$download_rds <- downloadHandler(
    filename = function() paste0("interactions-", input$selected_crop, "-", Sys.Date(), ".rds"),
    content = function(file) saveRDS(network_data()$records, file = file)
  )
}

shinyApp(ui, server)
