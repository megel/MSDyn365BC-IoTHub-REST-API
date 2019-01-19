page 50131 "MME IoT Hubs List"
{
    PageType = List;
    SourceTable = "MME IoT Hub";
    Caption = 'IoT-Hub List';
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; "Code")
                {
                    ApplicationArea = All;
                }
                field("IoT Hub Uri"; "IoT Hub Uri")
                {
                    ApplicationArea = All;
                }
                field("Authorization Token"; "Authorization Token")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
