on error ignore

:set-params:
policy_id = winnio_kafka_policy
db_name = winniio_db
table_name =  pillback_sensors
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
        "readings": "payload",
        "schema": {
            "timestamp": {
                "bring": "[timestamp]",
                "default": "now()",
                "type": "timestamp",
                "apply": "epoch_to_datetime",
                "root": true
            },
            "sensor_id": {
                "bring": "[sensorId]",
                "type": "int",
                "root": true
            },
            "type": {
                "bring": "[type]",
                "type": "string",
                "root": true
            },
            "id": {
                "bring": "[id]",
                "type": "int",
                "root": true
            },
            "sequence_number": {
                "bring": "[sequenceNumber]",
                "type": "int",
                "root": true
            },
            "battery": {
                "bring": "[battery]",
                "type": "float",
                "default": ""
            },
            "event_count": {
                "bring": "[eventCount]",
                "type": "int",
                "optional": true,
                "default": 0
            },
            "humidity": {
                "bring": "[humidity]",
                "type": "float",
                "optional": true,
                "default": ""
            },
            "temperature": {
                "bring": "[temperature]",
                "type": "float",
                "optional": true,
                "default": ""
            },
            "temperatureUnit": {
                "bring": "[temperatureUnit]",
                "type": "string",
                "optional": true,
                "default": ""
            },
            "switch": {
                "bring": "[switch]",
                "type": "bool",
                "optional": true,
                "default": false
            },
            "adcIn": {
                "bring": "[adcIn]",
                "type": "string",
                "optional": true,
                "default": ""
            },
            "adcMax": {
                "bring": "[adcMax]",
                "type": "string",
                "optional": true,
                "default": ""
            },
            "rs485": {
                "bring": "[rs485]",
                "type": "string",
                "optional": true,
                "default": ""
            },
            "co2value": {
                "bring": "[co2Value]",
                "type": "float",
                "optional": true,
                "default": ""
            },
            "trackingId": {
                "bring": "[trackingId]",
                "type": "int",
                "optional": true,
                "root": true,
                "default": 0
            },
            "num_hops": {
                "bring": "[numHops]",
                "type": "int",
                "root": true
            },
            "max_hops": {
                "bring": "[maxHops]",
                "type": "int",
                "root": true
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
