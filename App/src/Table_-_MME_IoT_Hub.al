table 50130 "MME IoT Hub"
{
    DataClassification = ToBeClassified;
    LookupPageId = "MME IoT Hubs List";


    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = SystemMetadata;
        }

        field(10; "IoT Hub Uri"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(11; "Authorization Token"; Text[250])
        {
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}