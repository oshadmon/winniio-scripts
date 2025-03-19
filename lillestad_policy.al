on error ignore

:set-params:
policy_id = lillestad_policy
db_name = winniio_db
table_name =  lillestad_sensors
set create_policy = true

:check-policy:
is_policy = blockchain get mapping where id = !policy_id
if !is_policy then goto end-script
else if not !is_policy and !create_policy == false then goto policy-error


:declare-policy:
<new_policy = {
    "mapping": {
        "id": !policy_id,
        "dbms": !db_name,
        "table": !table_name,
        "readings": "sensorPayload",
        "schema": {
            "sender": {
                "bring": "[Sender]",
                "type": "string",
                "default": "",
                "root": true
            },
            "timestamp": {
                "bring": "[timestamp]",
                "default": "now()",
                "type": "timestamp",
                "apply": "epoch_to_datetime"
            },
            "payload_type": {
                "bring": "[payloadType]",
                "type": "string",
                "default": ""
            },
            "sensor_id": {
                "bring": "[sensorId]",
                "type": "int"
            },
            "battery": {
                "bring": "[battery]",
                "type": "float"
            },
            "event_count": {
                "bring": "[eventCount]",
                "type": "int"
            },
            "temperature": {
                "bring": "[tempHumidity][temperature]",
                "type": "float"
            },
            "humidity": {
                "bring": "[tempHumidity][humidity]",
                "type": "float"
            },
            "adc_max": {
                "bring": "[tempHumidity][adcMax]",
                "type": "string",
                "default": ""
            },
            "adc_in": {
                "bring": "[tempHumidity][adcIn]",
                "type": "string",
                "default": ""
            }
        }
    }
}>

:publish-policy:
process !local_scripts/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_policy = false
goto check-policy

:end-script:
end script

:terminate-scripts:
exit scripts

:sign-policy-error:
print "Failed to sign mapping policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare member mapping policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare mapping policy on blockchain"
goto terminate-scripts

:policy-error:
print "Failed to publish policy for an unknown reason"
goto terminate-scripts
