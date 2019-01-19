page 50132 "MME IoT Device List"
{
    PageType = List;
    SourceTable = "MME IoT Device";
    Caption = 'IoT Device List';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTableView = sorting ("IoT Hub Code", "IoT Device ID") order(ascending);

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("IoT Hub Code"; "IoT Hub Code")
                {
                    ApplicationArea = All;
                    StyleExpr = mRecStyle;
                    Editable = mCanEditDevice;
                }
                field("IoT Device ID"; "IoT Device ID")
                {
                    ApplicationArea = All;
                    StyleExpr = mRecStyle;
                    Editable = mCanEditDevice;
                }
                field("Description"; "Description")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Connection State"; mDeviceStatus."Connection State")
                {
                    ApplicationArea = All;
                    StyleExpr = mConnectedStyle;
                    Editable = false;
                }
                field("Status"; mDeviceStatus."Status")
                {
                    ApplicationArea = All;
                    StyleExpr = mRecStyle;
                    Editable = false;
                }
                field("Status Updated Time"; mDeviceStatus."Status Updated Time")
                {
                    ApplicationArea = All;
                    StyleExpr = mRecStyle;
                    Editable = false;
                }
                field("Last Activity Time"; mDeviceStatus."Last Activity Time")
                {
                    ApplicationArea = All;
                    StyleExpr = mRecStyle;
                    Editable = false;
                }
                field("Cloud To Device Message Count"; mDeviceStatus."Cloud To Device Message Count")
                {
                    ApplicationArea = All;
                    StyleExpr = mRecStyle;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportDevices)
            {
                Caption = 'Import from IoT Hub';
                Image = Import;
                Promoted = true;
                ApplicationArea = All;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    mgt: Codeunit "MME IoT Management";
                begin
                    mgt.ImportDevices(Rec, mDeviceStatus);
                    CurrPage.Update(false);
                end;
            }

            action(EnableDevices)
            {
                Caption = 'Enable Device';
                Image = CheckList;
                Promoted = true;
                ApplicationArea = All;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    mgt: Codeunit "MME IoT Management";
                begin
                    mgt.UpdateDevice("IoT Hub Code", Rec, mDeviceStatus, mgt.CreateOrUpdateDevice(Rec, 'enabled'));
                    CurrPage.Update(false);
                end;
            }

            action(DisableDevices)
            {
                Caption = 'Disable Device';
                Image = CheckList;
                Promoted = true;
                ApplicationArea = All;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    mgt: Codeunit "MME IoT Management";
                begin
                    mgt.UpdateDevice("IoT Hub Code", Rec, mDeviceStatus, mgt.CreateOrUpdateDevice(Rec, 'disabled'));
                    CurrPage.Update(false);
                end;
            }

            separator(sep1)
            { }

            action(GetDevicesTwin)
            {
                Caption = 'Get Device Twin';
                Image = RelatedInformation;
                Promoted = true;
                ApplicationArea = All;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    mgt: Codeunit "MME IoT Management";
                    json: Text;
                begin
                    json := mgt.GetDeviceTwin(Rec);
                    if json <> '' then Message(json);
                end;
            }
        }
    }

    var
        mDeviceStatus: Record "MME IoT Device Status" temporary;
        mIoTMgt: Codeunit "MME IoT Management";
        mRecStyle: Text;
        mConnectedStyle: Text;
        mCanEditDevice: Boolean;

    trigger OnInit()
    var
        hub: Record "MME IoT Hub";
    begin
        mIoTMgt.GetDevices(hub, Rec, mDeviceStatus);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if not mDeviceStatus.Get("IoT Hub Code", "IoT Device ID") then
            mCanEditDevice := true
        else
            mCanEditDevice := mDeviceStatus.Status = 'not created';
    end;

    trigger OnAfterGetRecord()
    begin
        if not mDeviceStatus.Get("IoT Hub Code", "IoT Device ID") then
            mIoTMgt.GetDeviceStatus(Rec, mDeviceStatus);

        mRecStyle := '';
        if mDeviceStatus.IsEmpty() then begin
            mDeviceStatus.Init();
            mDeviceStatus."IoT Device ID" := "IoT Device ID";
            mDeviceStatus."IoT Hub Code" := "IoT Hub Code";
            mDeviceStatus.Status := 'not created';
            mDeviceStatus.Insert();
        end;

        case mDeviceStatus.Status of
            'enabled':
                mRecStyle := '';
            'disabled':
                mRecStyle := 'Subordinate';
            else begin
                    mRecStyle := 'Ambiguous';
                    mCanEditDevice := true;
                end;
        end;

        if mDeviceStatus.Status = 'enabled' then
            case mDeviceStatus."Connection State" of
                'Connected':
                    mConnectedStyle := 'Favorable';
                'Disconnected':
                    mConnectedStyle := 'Unfavorable';
            end
        else
            mConnectedStyle := mRecStyle;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        mCanEditDevice := true;
        mDeviceStatus.Init();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        mIoTMgt.CreateOrUpdateDevice(Rec, '');
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        mIoTMgt.DeleteDevice(Rec);
    end;
}
