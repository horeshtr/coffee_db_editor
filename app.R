#
# This Shiny web app allows for the management of a coffee brewing "database"
#   maintained in Google Sheets
#

library(shiny)
library(tidyverse)
library(googledrive)
library(googlesheets4)
library(lubridate)

#######################################################
# temporary setup code
#######################################################

# authenticate
drive_auth(email = NA)
gs4_auth(token = drive_token())
drive_user()

data_file <- drive_get("Coffee Brew Log")
metadata <- gs4_get(data_file)
s_sheet_id <- data_file$id
w_sheet_names <- sheet_names(data_file)
target_w_sheet <- w_sheet_names[1]

data <- read_sheet(
          ss = s_sheet_id, 
          sheet = target_w_sheet, 
          col_types = "iDcccccccDnnncniiiic"
        )
glimpse(data)
tail(data)

# Define UI for inputting brew data and outputting updated table
ui <- fluidPage(

    # Application title
    titlePanel("Coffee Brewing Data Editor"),

    # Sidebar with data inputs 
    sidebarLayout(
        sidebarPanel(
            
          # radio input to select edit or create new
            radioButtons(
              inputId = "record_type",
              label = "Select:",
              choices = c("Create New Record",
                          "Edit Existing Record")
              ),
            
            # dynamic input if input$record_type == "edit" then require BrewID
            
            # date input for (brew) Date
            dateInput(
              inputId = "brew_date",
              label = "Select the brew date:",
              value = today()
            ),
            
            # text input for Brew Method
            textInput(
              inputId = "method",
              label = "Enter brew method used:"
            ),
            
            # text input for Roaster
            textInput(
              inputId = "roaster",
              label = "Enter roaster name:"
            ),
            
            # text input for Origin
            textInput(
              inputId = "origin",
              label = "Enter country of origin:"
            ),
            
            # text input for Lot/Farm/Region
            textInput(
              inputId = "region",
              label = "Enter details about the lot, farm, and region:"
            ),
            
            # text input for Process
            textInput(
              inputId = "process",
              label = "Enter the processing method:"
            ),
            
            # text input for Variety
            textInput(
              inputId = "variety",
              label = "Enter the coffee varietal:"
            ),
            
            # text input for Altitude
            textInput(
              inputId = "altitude",
              label = "Enter the growing altitude:"
            ),
            
            # date input for Roast Date
            dateInput(
              inputId = "roast_date",
              label = "Select the roast date:"
            ),
            
            # number input for Coffee Weight (g)
            numericInput(
              inputId = "coffee_weight",
              label = "Enter the weight of coffee used for this brew:"
            ),
            
            # number input for Water Weight (g)
            numericInput(
              inputId = "water_weight",
              label = "Enter the weight of water used for this brew:"
            ),
            
            # text input for Grinder
            textInput(
              inputId = "grinder",
              label = "Enter the grinder used:"
            ),
            
            # number input for Grind Size
            numericInput(
              inputId = "grind_setting",
              label = "Enter the grind setting:"
            ),
            
            # number input for Flavor Score
            numericInput(
              inputId = "flavor_score",
              label = "Enter the flavor score:",
              min = 0,
              max = 5,
              step = 0.5
            ),
            
            # number input for Acidity Score
            numericInput(
              inputId = "acidity_score",
              label = "Enter the acidity score:",
              min = 0,
              max = 5,
              step = 0.5
            ),
            
            # number input for Sweetness Score
            numericInput(
              inputId = "sweet_score",
              label = "Enter the sweetness score:",
              min = 0,
              max = 5,
              step = 0.5
            ),
            
            # number input for Body Score
            numericInput(
              inputId = "body_score",
              label = "Enter the body score:",
              min = 0,
              max = 5,
              step = 0.5
            ),
            
            # text input for Notes
            textInput(
              inputId = "notes",
              label = "Enter notes about the brew:"
            )
            
          # ideally, text inputs would be select inputs based on existing values, 
          #   or "other" which opens a text input
        ),

        # Display outputs in the main panel
        mainPanel(
          # display table output
          datatableOutput(outputId = "table")
        )
    )
)

# Define server logic
server <- function(input, output) {
  # edit existing record or write new
  # if (input$record_type == "new") {
  #   # sheet_append(
  #     # data = create a table using input parameters, brew_id = max(brew_id) + 1
  #     # ss = sheet_id,
  #     # sheet = "Data"
  # } else {
  #   #sheet_write(
  #     # where input$brew_id == "brew_id"
  #     # data = create a table using input parameters,
  #     # ss = sheet_id,
  #     # sheet = "Data"
  #   #)
  # }
  
  # generate table output
  output$table <- renderDataTable(data)
}

# Run the application 
shinyApp(ui = ui, server = server)
