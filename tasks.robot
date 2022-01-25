########
# Rules
########
    #Save each order HTML receipt as a PDF file.
    #Save a screenshot of each of the ordered robots.
    #Embed the screenshot of the robot to the PDF receipt.
    #Create a ZIP archive of the PDF receipts (one zip archive that contains all the PDF files). Store the archive in the output directory.
    #Complete all the orders even when there are technical failures with the robot order website.
    #Use an assistant to ask some input from the human user, and then use that input some way.
    #Store the local vault file in the robot project repository so that it does not require manual setup.
    #Only the robot is allowed to get the orders file. You may not save the file manually on your computer.
    #Read some data from a local vault. In this case, do not store sensitive data such as credentials in the vault. The purpose is to verify that you know how to use the vault.
    #Be available in public GitHub repository.
    #It should be possible to get the robot from the public GitHub repository and run it without manual setup.

*** Settings ***
Documentation       Create robots order using the online order.csv file
Resource            KeywordsLibrary/RobotBinHTTP.robot

*** Tasks ***
Create Orders from Online CSV file
    ${ordersName}=   set variable            Commande  #Ask User the Report Name
    Download Order File
    Open The Order System in a Web Browser
    ${ordersTable}=     Read Order File
    Create Orders and save it as PDF     ${ordersTable}     ${ordersName}
    Compress Order Files     ${ordersName}
    
    [Teardown]  Delete Order File and Close Browser

    Log    Done.
    
