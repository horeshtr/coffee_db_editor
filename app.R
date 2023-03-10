#
# This Shiny web app allows for the management of a coffee brewing "database"
#   maintained in Google Sheets
#

library(shiny)
library(shinydashboard)
library(tidyverse)
library(dplyr)
library(googledrive)
library(googlesheets4)
library(lubridate)
library(DT)

#######################################################
# Initial setup code
#######################################################

# authenticate
drive_auth(email = NA)
gs4_auth(token = drive_token())
drive_user()

# Set the specific file and get metadata
data_file <- drive_get("Coffee Brew Log")

metadata_func <- function(file_name){
  base_data <- gs4_get(file_name)
  mod_time <- drive_reveal(file = file_name, what = "modified_time") %>%
    select(modified_time)
  cbind(base_data, mod_time)
}
metadata <- metadata_func(data_file)
last_modified <- max(metadata$modified_time)

# Get the spreadsheet ID
s_sheet_id <- data_file$id

# Get worksheet names
w_sheet_names <- sheet_names(data_file)

# Set the target worksheet to read from and write to
target_w_sheet <- w_sheet_names[1]

# Read in the existing data
data <- read_sheet(
  ss = s_sheet_id, 
  sheet = target_w_sheet, 
  col_types = "iDcccccccDnnncniiiic"
  )


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
                          "Edit Existing Record"),
              selected = "Create New Record"
              ),
            
            # dynamic input for BrewID depending on input$record_type selection
            uiOutput("brew_id"), 
            
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
            textAreaInput(
              inputId = "notes",
              label = "Enter notes about the brew:"
            ),
            
            # -> need to clean up button layout
            
            # action button to confirm changes
            actionButton(
              inputId = "confirm_data",
              label = "Confirm Brew Data",
              icon = icon("check", lib = "font-awesome")
            ),
            
            # action button to reset fields
            actionButton(
              inputId = "reset",
              label = "Reset Data Fields",
              icon = icon("eraser", lib = "font-awesome")
            ),
            
            # action button to enter changes
            actionButton(
              inputId = "write_data",
              label = "Add / Update Brew",
              icon = icon("download", lib = "font-awesome")
            ),
            
            # action button to refresh table
            actionButton(
              inputId = "refresh_table",
              label = "Refresh Table",
              icon = icon("arrows-rotate", lib = "font-awesome")
            )
            
          # -> ideally, text inputs would be select inputs based on existing values, 
          #   or "other" which opens a text input
        ),

        # Display outputs in the main panel
        mainPanel(
          # display table output
          DTOutput(outputId = "table")
        )
    )
)

# Define server logic
server <- function(input, output, session) {
  
  # reactive UI for entering BrewID based on record type selection
  output$brew_id <- renderUI({
    if(input$record_type == "Edit Existing Record") {
      numericInput(
        inputId = "brew_id", 
        label = "Enter Brew ID:",
        value = max(data$BrewID) - 10,
        min = min(data$BrewID),
        step = 1
      )
    }
  })
  
  # create data frame from inputs when update_table is pressed
  change_record <- eventReactive(
    input$confirm_data,
    data.frame(
      BrewID = if (input$record_type == "Create New Record") {max(data$BrewID) + 1
      } else {
          BrewID = input$brew_id
        },
      Date = as.Date(input$brew_date, "%Y/%m/%d"),   
        # ^ writes to sheet in 2023-01-07 format, same for roast date
      Brew_Method = input$method,
      Roaster = input$roaster,  
        # ^ writes to sheet in italics
      Origin = input$origin,
      Lot_Farm_Region = input$region,
      Process = input$process,
      Variety = input$variety,
      Altitude = input$altitude,
      Roast_Date = as.Date(input$roast_date, "%Y/%m/%d"), 
      Coffee_Weight_g = input$coffee_weight,
      Water_Weight_g = input$water_weight,
      Brew_Ratio = input$water_weight / input$coffee_weight,
      Grinder = input$grinder,
      Grind_Size = input$grind_setting,
      Flavor_Score = input$flavor_score,
      Acidity_Score = input$acidity_score,
      Sweetness_Score = input$sweet_score,
      Body_Score = input$body_score,
      Notes = input$notes
    )  
  )
  # Are fields formatted correctly? Dates do not seem to be when they write to Sheets
  
  # Confirmation Message
  observeEvent(
    input$confirm_data, {
    showModal(modalDialog("Data Confirmed!", size = "s", easyClose = TRUE))
    }
  )
  
  # Reset values if reset button is pressed
  observeEvent(
    input$reset, {
      updateNumericInput(inputId = "brew_id", value = max(data$BrewID) - 10)
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
      updateTextAreaInput(inputId = "notes", value = "")
      
      showModal(modalDialog("Data fields reset.", size = "s", easyClose = TRUE))
  })
  
  # edit existing record or write new when write_data button is pressed
  observeEvent(
    input$write_data, {
      if (input$record_type == "Create New Record") {
        sheet_append(
        data = change_record(),
        ss = s_sheet_id,
        sheet = target_w_sheet
        # is there an equivalent to reformat arg or should I use range_write instead?
        )
      } else {
        
        row <- input$brew_id + 1
        range <- paste0("A", row, ":", "T", row)
        
        range_write(
          ss = s_sheet_id,
          data = change_record(),
          sheet = target_w_sheet,
          range = range,
          col_names = FALSE,
          reformat = FALSE
        )
      }

    }
  )
  
  # Generate table output
  data_refresh <- eventReactive(
    input$refresh_table, {
      read_sheet(
        ss = s_sheet_id, 
        sheet = target_w_sheet, 
        col_types = "iDcccccccDnnncniiiic"
      )
    },
    ignoreNULL = FALSE
  )
  
  output$table <- renderDT(
    data_refresh(),
    options = list(
      pageLength = 10,
      lengthMenu = c(5, 10, 20),
      order = list(1, "desc"),
      rownames = FALSE,
      class = "cell-border stripe", # -> still not displaying
      autoWidth = TRUE,
      scrollX = TRUE, scrollY = 600,
      scrollCollapse=TRUE,
      columnDefs = list(list(width = '300px', targets = c(6,20)))
    )
  )

}

# Run the application 
shinyApp(ui = ui, server = server)
