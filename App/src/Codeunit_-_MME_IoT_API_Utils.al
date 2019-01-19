codeunit 50132 "MME IoT API Utils"
{
    procedure Prepare(client: HttpClient; hubCode: Code[20]; api: Enum "MME IoT API")
    begin
        Prepare(client, hubCode, '', api, '');
    end;

    procedure Prepare(client: HttpClient; hubCode: Code[20]; id: Text; api: Enum "MME IoT API")
    begin
        Prepare(client, hubCode, id, api, '');
    end;

    procedure Prepare(client: HttpClient; hubCode: Code[20]; id: Text; api: Enum "MME IoT API"; ifMatch: Text)
    var
        hub: Record "MME IoT Hub";
    begin
        if not hub.Get(hubCode) then exit;
        if (hub."IoT Hub Uri" = '') or (hub."Authorization Token" = '') then exit;
        Clear(client);
        client.DefaultRequestHeaders().Add('Authorization', hub."Authorization Token");

        if ifMatch <> '' then
            client.DefaultRequestHeaders().Add('If-Match', ifMatch);

        // The URL's of the IoT Hub REST API
        case api of
            api::GetDevices:
                client.SetBaseAddress(StrSubstNo('%1/devices?api-version=2018-06-30', hub."IoT Hub Uri"));

            api::GetDevice,
            api::CreateOrUpdateDevice,
            api::DeleteDevice:
                client.SetBaseAddress(StrSubstNo('%1/devices/%2?api-version=2018-06-30', hub."IoT Hub Uri", id));

            api::GetConfiguration,
            api::CreateOrUpdateConfiguration,
            api::DeleteConfiguration:
                client.SetBaseAddress(StrSubstNo('%1/configurations/%2?api-version=2018-06-30', hub."IoT Hub Uri", id));

            api::GetTwin,
            api::UpdateTwin,
            api::ReplaceTwin:
                client.SetBaseAddress(StrSubstNo('%1/twins/%2?api-version=2018-06-30', hub."IoT Hub Uri", id));

            api::InvokeDeviceMethod:
                client.SetBaseAddress(StrSubstNo('%1/twins/%2/methods?api-version=2018-06-30', hub."IoT Hub Uri", id));
        end;
    end;


    procedure Prepare(request: HttpRequestMessage; api: Enum "MME IoT API")
    begin
        Prepare(request, api, '');
    end;

    procedure Prepare(request: HttpRequestMessage; api: Enum "MME IoT API"; json: Text)
    var
        headers: HttpHeaders;
        content: HttpContent;
    begin
        // Prepare the request (Content, Header & Method)
        case api of
            api::CreateOrUpdateDevice,          // https://docs.microsoft.com/en-us/rest/api/iothub/service/createorupdatedevice
            api::CreateOrUpdateConfiguration,   // https://docs.microsoft.com/en-us/rest/api/iothub/service/createorupdateconfiguration
            api::ReplaceTwin:                   // https://docs.microsoft.com/en-us/rest/api/iothub/service/replacetwin
                begin
                    // Assign the Json-Content
                    content.WriteFrom(json);
                    // Change of the message header must be here, because writing the content may reset these header to: "Text/Plain"
                    content.GetHeaders(headers);
                    headers.Remove('Content-Type');
                    headers.Add('Content-Type', 'application/json');
                    // Assign the content & HTTP-Method
                    request.Content(content);
                    request.Method('PUT');
                end;

            api::DeleteDevice,                  // https://docs.microsoft.com/en-us/rest/api/iothub/service/deletedevice
            api::DeleteConfiguration:           // https://docs.microsoft.com/en-us/rest/api/iothub/service/deleteconfiguration
                request.Method('DELETE');

            api::GetDevices,                    // https://docs.microsoft.com/en-us/rest/api/iothub/service/getdevices
            api::GetDevice,                     // https://docs.microsoft.com/en-us/rest/api/iothub/service/getdevice
            api::GetConfiguration,              // https://docs.microsoft.com/en-us/rest/api/iothub/service/getconfiguration
            api::GetTwin:                       // https://docs.microsoft.com/en-us/rest/api/iothub/service/gettwin
                request.Method('GET');

            api::UpdateTwin:                    // https://docs.microsoft.com/en-us/rest/api/iothub/service/updatetwin
                begin
                    // Assign the Json-Content
                    content.WriteFrom(json);
                    // Change of the message header must be here, because writing the content may reset these header to: "Text/Plain"
                    content.GetHeaders(headers);
                    headers.Remove('Content-Type');
                    headers.Add('Content-Type', 'application/json');
                    // Assign the content & HTTP-Method
                    request.Content(content);
                    request.Method('PATCH');
                end;

            api::InvokeDeviceMethod:
                begin
                    // Assign the Json-Content
                    content.WriteFrom(json);
                    // // Change of the message header must be here, because writing the content may reset these header to: "Text/Plain"
                    // content.GetHeaders(headers);
                    // headers.Remove('Content-Type');
                    // headers.Add('Content-Type', 'application/json');
                    // Assign the content & HTTP-Method
                    request.Content(content);
                    request.Method('POST');
                end;
        end;
    end;
}