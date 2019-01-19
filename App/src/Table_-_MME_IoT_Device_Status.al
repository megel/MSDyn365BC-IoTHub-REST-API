table 50132 "MME IoT Device Status"
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

        field(11; "Connection State"; Text[50])
        {
            DataClassification = CustomerContent;
        }

        field(12; "Status"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(13; "Status Updated Time"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(14; "Last Activity Time"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(15; "Cloud To Device Message Count"; Integer)
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