table 50131 "MME IoT Device"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "IoT Hub Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "MME IoT Hub".Code;
        }

        field(2; "IoT Device ID"; Text[50])
        {
            DataClassification = CustomerContent;
        }

        field(3; "Description"; Text[50])
        {
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(PK; "IoT Hub Code", "IoT Device ID")
        {
            Clustered = true;
        }
    }
}