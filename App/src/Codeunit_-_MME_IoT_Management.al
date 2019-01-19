codeunit 50131 "MME IoT Management"
{
    var
        iotUtils: Codeunit "MME IoT API Utils";

    procedure ImportDevices(var device: Record "MME IoT Device"; var deviceStatus: Record "MME IoT Device Status" temporary)
    var
        hub: Record "MME IoT Hub";
        page: Page "MME IoT Hubs List";
    begin
        // Lookup the Hub
        page.SetRecord(hub);
        page.LookupMode(true);
        if page.RunModal() <> Action::LookupOK then exit;
        page.SetSelectionFilter(hub);

        // Add all devices from Hub
        GetDevices(hub, device, deviceStatus);
    end;

    procedure GetDeviceStatus(device: Record "MME IoT Device"; var iotDeviceStatus: Record "MME IoT Device Status" temporary)
    var
        hub: Record "MME IoT Hub";
    begin
        if not iotDeviceStatus.Get(device."IoT Hub Code", device."IoT Device ID") then begin
            iotDeviceStatus.Init();
            iotDeviceStatus."IoT Hub Code" := device."IoT Hub Code";
            iotDeviceStatus."IoT Device ID" := device."IoT Device ID";
            iotDeviceStatus.Status := 'not created';
            iotDeviceStatus.Insert();
        end;
        if not hub.Get(device."IoT Hub Code") then exit;
        if (hub."IoT Hub Uri" = '') or (hub."Authorization Token" = '') then exit;

        UpdateDevice(hub.Code, device, iotDeviceStatus, GetDevice(device));
    end;

    procedure GetDevices(var iotHub: Record "MME IoT Hub"; var iotDevices: Record "MME IoT Device"; var iotDeviceStatus: Record "MME IoT Device Status" temporary)
    begin
        if iotHub.FindSet() then
            repeat
                UpdateDevice(iotHub.Code, iotDevices, iotDeviceStatus, GetDevices(iotHub.Code));
            until iotHub.Next() = 0;
    end;


    procedure GetDevice(var device: Record "MME IoT Device") deviceJson: Text
    var
        api: Enum "MME IoT API";
        client: HttpClient;
        response: HttpResponseMessage;
        request: HttpRequestMessage;
        json: Text;
    begin
        api := api::GetDevice;

        iotUtils.Prepare(client, device."IoT Hub Code", device."IoT Device ID", api);
        iotUtils.Prepare(request, api, json);

        if not client.Send(request, response) then exit;
        if not response.IsSuccessStatusCode() then begin
            HandleError(response);
            exit;
        end;
        if not response.Content().ReadAs(deviceJson) then exit;
        exit(deviceJson);
    end;

    procedure GetDevices(hubCode: Code[20]) devicesJson: Text
    var
        api: Enum "MME IoT API";
        client: HttpClient;
        response: HttpResponseMessage;
        request: HttpRequestMessage;
    begin
        api := api::GetDevices;

        iotUtils.Prepare(client, hubCode, api);
        iotUtils.Prepare(request, api);

        if not client.Send(request, response) then exit;
        if not response.IsSuccessStatusCode() then begin
            HandleError(response);
            exit;
        end;
        if not response.Content().ReadAs(devicesJson) then exit;
        exit(devicesJson);
    end;

    procedure CreateOrUpdateDevice(var device: Record "MME IoT Device"; status: Text) deviceJson: Text
    var
        api: Enum "MME IoT API";
        client: HttpClient;
        response: HttpResponseMessage;
        request: HttpRequestMessage;
        json: Text;
        ifMatch: Text;
        jObject: JsonObject;
    begin
        api := api::CreateOrUpdateDevice;

        if status <> '' then begin
            ifMatch := '*';
            jObject.Add('status', status)
        end;
        jObject.Add('deviceId', device."IoT Device ID");
        jObject.WriteTo(json);

        iotUtils.Prepare(client, device."IoT Hub Code", device."IoT Device ID", api, ifMatch);
        iotUtils.Prepare(request, api, json);

        if not client.Send(request, response) then exit;
        if not response.IsSuccessStatusCode() then begin
            HandleError(response);
            exit;
        end;
        if not response.Content().ReadAs(deviceJson) then exit;
        exit(deviceJson);
    end;

    procedure DeleteDevice(var device: Record "MME IoT Device")
    var
        api: Enum "MME IoT API";
        client: HttpClient;
        response: HttpResponseMessage;
        request: HttpRequestMessage;
    begin
        api := api::DeleteDevice;

        iotUtils.Prepare(client, device."IoT Hub Code", device."IoT Device ID", api, '*');
        iotUtils.Prepare(request, api);

        if not client.Send(request, response) then exit;
        if not response.IsSuccessStatusCode() then begin
            HandleError(response);
            exit;
        end;
    end;


    procedure GetDeviceTwin(var device: Record "MME IoT Device") devicesJson: Text
    var
        api: Enum "MME IoT API";
        client: HttpClient;
        response: HttpResponseMessage;
        request: HttpRequestMessage;
        json: Text;
    begin
        api := api::GetTwin;

        iotUtils.Prepare(client, device."IoT Hub Code", device."IoT Device ID", api);
        iotUtils.Prepare(request, api, json);

        if not client.Send(request, response) then exit;
        if not response.IsSuccessStatusCode() then begin
            HandleError(response);
            exit;
        end;
        if not response.Content().ReadAs(devicesJson) then exit;
        exit(devicesJson);
    end;

    procedure GetConfig(hubCode: Code[20]; id: text) devicesJson: Text
    var
        api: Enum "MME IoT API";
        client: HttpClient;
        response: HttpResponseMessage;
        request: HttpRequestMessage;
        json: Text;
    begin
        api := api::GetConfiguration;

        iotUtils.Prepare(client, hubCode, id, api);
        iotUtils.Prepare(request, api, json);

        if not client.Send(request, response) then exit;
        if not response.IsSuccessStatusCode() then begin
            HandleError(response);
            exit;
        end;
        if not response.Content().ReadAs(devicesJson) then exit;
        exit(devicesJson);
    end;

    local procedure HandleError(response: HttpResponseMessage)
    var
        headers: HttpHeaders;
        rValues: array[10] of Text;
        json: Text;
    begin
        headers := response.Headers();
        if headers.Contains('iothub-errorcode') then begin
            headers.GetValues('iothub-errorcode', rValues);

            if response.Content().ReadAs(json) then;
            Message('%1\HttpStatusCode:%2\%3\%4', response.ReasonPhrase(), response.HttpStatusCode(), rValues[1], json);
        end;
    end;


    procedure UpdateDevice(hubCode: Code[20]; var device: Record "MME IoT Device" temporary; var deviceStatus: Record "MME IoT Device Status" temporary; deviceJson: Text)
    var
        jObject: JsonObject;
        jArray: JsonArray;
        jToken: JsonToken;
    begin
        if deviceJson = '' then exit;
        if not jArray.ReadFrom(deviceJson) then begin
            if not jObject.ReadFrom(deviceJson) then exit;
            jArray.Add(jObject);
        end;
        foreach jToken in jArray do
            if jToken.IsObject() then begin
                GetDeviceStatus(hubCode, jToken.AsObject(), deviceStatus);

                // Insert missing devices
                if not deviceStatus.IsEmpty() then
                    if not device.Get(deviceStatus."IoT Hub Code", deviceStatus."IoT Device ID") then begin
                        device.Init();
                        device."IoT Hub Code" := deviceStatus."IoT Hub Code";
                        device."IoT Device ID" := deviceStatus."IoT Device ID";
                        device.Insert();
                    end;
            end;
    end;

    local procedure GetDeviceStatus(huCode: Code[20]; jDevice: JsonObject; var deviceStatus: Record "MME IoT Device Status" temporary)
    var
        k: Text;
        jToken: JsonToken;
    begin
        deviceStatus.Init();
        deviceStatus."IoT Hub Code" := huCode;
        foreach k in jDevice.Keys() do begin

            jDevice.Get(k, jToken);
            if jToken.IsValue() then
                if not jToken.AsValue().IsNull() then
                    case k of
                        'deviceId':
                            deviceStatus."IoT Device ID" := jToken.AsValue().AsText();
                        'connectionState':
                            deviceStatus."Connection State" := jToken.AsValue().AsText();
                        'status':
                            deviceStatus.Status := jToken.AsValue().AsText();
                        'statusUpdatedTime':
                            deviceStatus."Status Updated Time" := jToken.AsValue().AsDateTime();
                        'lastActivityTime':
                            deviceStatus."Last Activity Time" := jToken.AsValue().AsDateTime();
                        'cloudToDeviceMessageCount':
                            deviceStatus."Cloud To Device Message Count" := jToken.AsValue().AsInteger();
                    end;
        end;
        if not deviceStatus.Insert() then
            deviceStatus.Modify();
    end;
}