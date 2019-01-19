enum 50130 "MME IoT API"
{
    Extensible = true;

    value(0; GetDevices) { }

    value(1; GetDevice) { }

    value(2; CreateOrUpdateDevice) { }

    value(3; DeleteDevice) { }

    value(10; GetConfigs) { }

    value(11; GetConfiguration) { }

    value(12; CreateOrUpdateConfiguration) { }

    value(13; DeleteConfiguration) { }

    value(21; GetTwin) { }

    value(22; UpdateTwin) { }

    value(23; ReplaceTwin) { }

    value(31; InvokeDeviceMethod) { }
}