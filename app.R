#
# This Shiny web app allows for the management of a coffee brewing "database"
#   maintained in Google Sheets
#

library(shiny)
library(tidyverse)
library(googledrive)
library(googlesheets4)

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

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            # radio input to select edit or create new
            radioButtons(
              inputId = "record_type",
              label = "Select:",
              choices = c("Create New Record" = "new",
                          "Edit Existing Record" = "edit")
              ),
            
            # dynamic input if input$record_type == "edit" then require brew_id
            
            # date input for brew date
            dateInput(
              inputId = "brew_date",
              label = "Select the brew date:",
              value = today()
            )
            # text input for roaster
            # text input for country of origin
            # text input for lot/farm/region
            # text input for process
            # text input for variety
            # text input for altitude
            # date input for roast date
            # number input for coffee weight
            # number input for water weight
            # text input for grinder
            # number input for grind setting
            # number input for flavor score
            # number input for acidity score
            # number input for sweetness score
            # number input for body score
            # text input for notes
          
          # ideally, text inputs would be select inputs based on existing values, 
          #   or "other" which opens a text input
        ),

        # Show a plot of the generated distribution
        mainPanel(
           # display table output
        )
    )
)

# Define server logic
server <- function(input, output) {
  # edit existing record or write new
  if (input$record_type == "new") {
    # sheet_append(
      # data = create a table using input parameters, brew_id = max(brew_id) + 1
      # ss = sheet_id,
      # sheet = "Data"
  } else {
    #sheet_write(
      # where input$brew_id == "brew_id"
      # data = create a table using input parameters,
      # ss = sheet_id,
      # sheet = "Data"
    #)
  }
  # generate table output
  
}

# Run the application 
shinyApp(ui = ui, server = server)
