*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library    RPA.Browser.Selenium    auto_close=${FALSE}
Library    RPA.FileSystem
Library    RPA.Excel.Files
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.Desktop.Windows
Library    RPA.PDF

*** Variables ***
${URL}=                  https://robotsparebinindustries.com/
${ordersCSVFile}=        https://robotsparebinindustries.com/orders.csv
${ordersFile}=           orders.csv
${orderYourRobot}=       //*[@id="root"]/header/div/ul/li[2]/a
${popup_xpath}=          //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
${head_locator}=         //*[@id="head"]
${legs_locator}=         //input[@class='form-control'][@type='number']
${address_locator}=      //*[@id="address"]
${preview_locator}=      //*[@id="preview"]
${submit_locator}=       //*[@id="order"]
${receipt_locator}=      //div[@id="receipt"]
${receipts}=             Receipts
${order_another}=        //button[@id="order-another"]

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    Close the annoying modal
    Loop orders

    # ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
    #     ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
    #     Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
    #     Go to order another robot
    # END
    # Create a ZIP file of the receipts
    
*** Keywords ***

Open the robot order website

    Open Available Browser        ${URL} 
    Click Element                ${orderYourRobot}
Get orders

    Download         ${ordersCSVFile}    overwrite=True
    ${orders}=       Read table from CSV    ${ordersFile}    header=True   
    RETURN           ${orders}

Close the annoying modal
    
    Click Button When Visible    ${popup_xpath}

Loop orders
    ${orders}=    Read table from CSV    ${ordersFile}    header=True   
    FOR    ${row}    IN    @{orders}
        Fill the form    ${row}   
    END

# Preview the robot
#     Click Button    ${preview_locator}

Submit the order
    Click Button    ${submit_locator}

Element is Visible
    Wait Until Element Is Visible    ${receipt_locator} 

Store the receipt as a PDF file

    #Wait Until Page Contains Element    ${receipt_locator} 
    [Arguments]    ${row}
    Wait Until Keyword Succeeds    5x    1 sec    Element is Visible
    ${receipt_results_html}=    Get Element Attribute    ${receipt_locator}    outerHTML
    ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
    Html To Pdf    ${receipt_results_html}    ${OUTPUT_DIR}${/}${receipts}${/}${pdf}

Fill the form
   [Arguments]    ${row}
    Select From List By Index                ${head_locator}    ${row}[Head]
    Select Radio Button                      body    ${row}[Body]
    Input Text                               ${legs_locator}    ${row}[Legs]
    Input Text                               ${address_locator}    ${row}[Address]
    # Click Button                             ${preview_locator}
    # Preview the robot
    Submit the order
    Store the receipt as a PDF file         ${row}
    Click Button    ${order_another}
    Close the annoying modal
