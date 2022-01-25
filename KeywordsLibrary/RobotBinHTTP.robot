***Settings***
Library     RPA.Archive
Library     RPA.Browser.Selenium    auto_close=${FALSE}
Library     RPA.Dialogs
Library     RPA.FileSystem
Library     RPA.HTTP
Library     RPA.PDF
Library     RPA.Robocloud.Secrets    #RPA.Robocorp.Vault
Library     RPA.Tables




***Variables***
${robot-preview-image}=     output/robot-preview-image.png


****Keywords***
Download Order File
    ${robotSpareBin} =    Get Secret    robotSpareBin    
    Download      url=${robotSpareBin}[CSVOrder]    overwrite=true  target_file=./DataSets/order.csv


Ask User the Report Name
    Add text input    ordersName    label=Enter the name of the order
    ${response}=    Run dialog
    [Return]    ${response.ordersName}
    
    
Open The Order System in a Web Browser
    
    Open Available Browser      https://robotsparebinindustries.com/#/robot-order


Accept the Term and Conditions
    Wait Until Page Contains    By using this order form
    Click button       OK
    
    


Read Order File
    ${OrdersTable}=     Read table from CSV     path=./DataSets/order.csv   header=True
    
    log     ${OrdersTable}
    [Return]    ${OrdersTable}


Create Orders and save it as PDF
    [Arguments]     ${OrdersTable}      ${ordersName}
    FOR    ${order}    IN    @{OrdersTable}
        Accept the Term and Conditions
        log    ${order}
        Fill the Order Form     ${order}    ${ordersName}
   
    END
  



Fill the Order Form
    [Arguments]  ${order}   ${ordersName}
    # Head
    Select From List By Value   id:head     ${order}[Head]
    
    # Body
    log                                     ${order}[Body]
    Select Radio Button    body             ${order}[Body]
    
    #Legs
    Input Text      xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${order}[Legs]
       
    #Address
    Input Text      address                 ${order}[Address]
    Click Button    id:preview
    
    # Take a screenshot of the robot
    Wait Until Page Contains Element    locator=id:robot-preview-image
    sleep                               1
    Screenshot                          locator=id:robot-preview-image      filename=${robot-preview-image}
    
    Click Button    id:order
    ${orderButtonText}=     Does Page Contain Button  Order
    FOR    ${i}    IN RANGE    9999999
        ${orderAnotherRobotButtonText}=     Does Page Contain Button    Order another robot
        ${shouldWeExit}=                    Evaluate    ${orderAnotherRobotButtonText} == True
        Exit For Loop If                    ${shouldWeExit}
        Get Source
        #Sleep           3
        Click Button    id:order
    END
    ${orderDetails}=     get element attribute           id:receipt    outerHTML
  


    # Create PDF files
    Download  https://robotsparebinindustries.com/static/css/2.9efb3193.chunk.css   overwrite=true  target_file=output/style.css
    Set Suite Variable  &{DATA}         orderData=${orderDetails}
    ...                                 robotPicture=${robot-preview-image}
    ...                                 style=output/style.css

    log     ${DATA}
  
    
    Template Html To Pdf    
    ...                 Assets/order.template
    ...                 ./output/${ordersName}-${order}[Order number].pdf
    ...                 ${DATA}

    
    #sleep           3
    Click Button    order-another



#####
# Compress all PDF order files in a zip file
#####
Compress Order Files
    [Arguments]      ${ordersName}
    Archive Folder With Zip    ./output/     ./output/${ordersName}.zip  include=${ordersName}*.pdf

#####
# Cleanup after the robot. Romove the order file and all files created during the execution
# exept the zip file containning all PDF
#####
Delete Order File and Close Browser
    ${PDFFiles}=    Find Files  output/*.pdf

    Remove File     DataSets/order.csv
    Remove File     output/robot-preview-image.png
    Remove File     output/style.css
    FOR  ${PDFFile}  IN   @{PDFFiles}
       Remove File    ${PDFFile}
       log  ${PDFFile}
    END
    Close Browser