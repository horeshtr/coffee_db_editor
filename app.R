#
# This Shiny web app allows for the management of a coffee brewing "database"
#   maintained in Google Sheets
#

library(shiny)
library(tidyverse)
library(dplyr)
library(googledrive)
library(googlesheets4)
library(lubridate)
library(DT)

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


#######################################################
# app code
#######################################################

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
              label = "Enter the weight of coffee used for this brew:",
              value = 0
            ),
            
            # number input for Water Weight (g)
            numericInput(
              inputId = "water_weight",
              label = "Enter the weight of water used for this brew:",
              value = 0
            ),
            
            # text input for Grinder
            textInput(
              inputId = "grinder",
              label = "Enter the grinder used:"
            ),
            
            # number input for Grind Size
            numericInput(
              inputId = "grind_setting",
              label = "Enter the grind setting:",
              value = 0
            ),
            
            # number input for Flavor Score
            numericInput(
              inputId = "flavor_score",
              label = "Enter the flavor score:",
              value = 0,
              min = 0,
              max = 5,
              step = 0.5
            ),
            
            # number input for Acidity Score
            numericInput(
              inputId = "acidity_score",
              label = "Enter the acidity score:",
              value = 0,
              min = 0,
              max = 5,
              step = 0.5
            ),
            
            # number input for Sweetness Score
            numericInput(
              inputId = "sweet_score",
              label = "Enter the sweetness score:",
              value = 0,
              min = 0,
              max = 5,
              step = 0.5
            ),
            
            # number input for Body Score
            numericInput(
              inputId = "body_score",
              label = "Enter the body score:",
              value = 0,
              min = 0,
              max = 5,
              step = 0.5
            ),
            
            # text input for Notes
            textInput(
              inputId = "notes",
              label = "Enter notes about the brew:"
            ),
            
            # action button to enter changes
            actionButton(
              inputId = "update_table",
              label = "Add / Update Brew"
            ),
            
            # action button to reset fields
            actionButton(
              inputId = "reset",
              label = "Reset Data Fields"
            )
            
          # ideally, text inputs would be select inputs based on existing values, 
          #   or "other" which opens a text input
        ),

        # Display outputs in the main panel
        mainPanel(
          # display table output
          dataTableOutput(outputId = "table")
        )
    )
)

# Define server logic
server <- function(input, output) {
  
  # Reset values
  observeEvent(input$reset, {
    updateDateInput(inputId = "brew_date", value = today())
    updateTextInput(inputId = "method", value = "")
    updateTextInput(inputId = "roaster", value = "")
    updateTextInput(inputId = "origin", value = "")
    updateTextInput(inputId = "region", value = "")
    updateTextInput(inputId = "process", value = "")
    updateTextInput(inputId = "variety", value = "")
    updateTextInput(inputId = "altitude", value = "")
    updateDateInput(inputId = "roast_date", value = today())
    updateNumericInput(inputId = "coffee_weight", value = 0)
    updateNumericInput(inputId = "water_weight", value = 0)
    updateTextInput(inputId = "grinder", value = "")
    updateNumericInput(inputId = "grind_setting", value = 0)
    updateNumericInput(inputId = "flavor_score", value = 0)
    updateNumericInput(inputId = "acidity_score", value = 0)
    updateNumericInput(inputId = "sweet_score", value = 0)
    updateNumericInput(inputId = "body_score", value = 0)
    updateTextInput(inputId = "notes", value = "")
  })
  
  # pull column names from data source
  reactive(
    column_names <- colnames(data)
  )
  
  # create data frame from inputs
  reactive(
    change_record <- data.frame(
      BrewID = if (input$record_type == "new") {max(BrewID) + 1
      } else {
          BrewID = input$brew_id
        },
      Date = input$brew_date,
      BrewMethod = input$method,
      Roaster = input$roaster,
      Origin = input$origin,
      Lot = input$region
      # not complete
      # need to fix column names
      # can I do this dynamically?
    )  
  )
  
  # edit existing record or write new
  eventReactive(
    input$update_table, {
      if (input$record_type == "new") {
        sheet_append(
        data = change_record,
        ss = sheet_id,
        sheet = "Data"
        )
      } else {
        sheet_write(
          # where input$brew_id == "brew_id",
          data = change_record,
          ss = sheet_id,
          sheet = "Data"
        )
      }

    }
  )
  
  # generate table output
  output$table <- renderDataTable(
    data,
    options = list(
      pageLength = 25#,
      #order = "desc"
    )
  )
}

# Run the application 
shinyApp(ui = ui, server = server)
