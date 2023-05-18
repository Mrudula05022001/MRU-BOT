*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library             RPA.Browser.Selenium          auto_close=${False}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive

*** Keywords ***
Open the robot order website
    #ToDo: Implement your keyword here
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order    maximized=True
    Click Button    OK 

Get Orders
    Download     https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${OrdersTable}=    Read table from CSV    orders.csv    dialect=excel    header=True    
    RETURN    ${OrdersTable}
Fill the Form
    [Arguments]    ${Ordering}
    Select From List By Value    head   ${Ordering}[Head]
    Select Radio Button    body   ${Ordering}[Body]
    Input Text    xpath: //input[@type="number"]    ${Ordering}[Legs]
    Input Text    xpath://input[@type="text"]    ${Ordering}[Address]
    Click Button    preview
    Wait Until Element Is Visible    robot-preview-image
    #Click Button    order
    Wait Until Keyword Succeeds    3x    0.5s    Click Button    order
    #Wait Until Element Is Visible    id:receipt    7s
    ${pdf}=    Store the receipt as a PDF file    ${Ordering}[Order number]
    ${screenshot}=    Take a screenshot of the robot    ${Ordering}[Order number]
    Log    ${pdf}
    Embed the robot screenshot to the receipt pdf file    ${screenshot}    ${pdf}
    Click Button    order-another
    Wait Until Keyword Succeeds    3x    0.5s    Click Button    OK    
    #Click Button    OK
    Creating a zip Archive    ${pdf}
Creating a zip Archive
    [Arguments]    ${pdf}
    Archive Folder With Zip    ${OUTPUT_DIR}${/}output${/}receipts    receipts_all.zip    recursive=True 
    Add To Archive    ${pdf}.pdf    receipts_all.zip   

Store the receipt as a PDF file
    [Arguments]    ${order}
    Wait Until Element Is Visible    id:receipt    10 
    ${HTMLelement}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${HTMLelement}    ${OUTPUT_DIR}${/}output${/}receipts${/}${order}.Pdf
    RETURN    ${OUTPUT_DIR}${/}output${/}receipts${/}${order}
Take a screenshot of the robot
    [Arguments]    ${order}
    Screenshot    //div[@id="robot-preview"]   ${OUTPUT_DIR}${/}output${/}screenshots${/}${order}.png 
    RETURN    ${OUTPUT_DIR}${/}output${/}screenshots${/}${order}  
Embed the robot screenshot to the receipt pdf file
    [Arguments]    ${screenshots}    ${pdf}
    ${screenshotlist}=    Create List
    ...    ${screenshots}.png
    ...    ${pdf}.pdf 
    #Open Pdf    ${pdf}.pdf
    Add Files To Pdf    ${screenshotlist}    ${pdf}.pdf
    #Close Pdf    ${pdf}.pdf           

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${Orders}=    Get Orders
    FOR    ${Order}    IN    @{Orders}
        #Log    ${Order}
        Fill the Form    ${Order}  
    END
    #Fill the form    ${Orders} 


    
    
