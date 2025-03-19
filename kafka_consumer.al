#----------------------------------------------------------------------------------------------------------------------#
# Kafka client for winnio use case
# :step to update:
#   1. bring down network -- make down EDGELAKE_TYPE=[NODE_TYPE]
#   2. remove databases (including blockchain) -- for db in blockchain winnio_db almgm ; do psql -h 127.0.0.1 -p 5432 -U winnio -c "DROP DATABASE IF EXISTS ${db}" ; done
#   3. In operator nodes update local scripts to this
#   4. bring nodes up --  make up EDGELAKE_TYPE=[NODE_TYPE]
# :kafka-client:
# <run kafka consumer where
#    ip = "135.225.106.191"
#    and port = 9092
#    and reset = "earliest"
#    and topic = (
#        name = "pilback.data"
#        and dbms = "winniio_db"
#        and table = "pillback_sensors"
#        and column.timestamp = (type = "date" and value = "bring [timestamp]") X
#        and column.type = (type = "string" and value = "bring [type]") X
#        and column.system_id = (type = "string" and value = "bring [sensorId]")
#        and column.sequence_number = (type = "int" and value = "bring [sequenceNumber]")
#        and column.battery = (type = "float" and value = "bring [payload][battery]")
#        and column.event_count = (optional = true and type = "int" and value = "bring [payload][eventCount]")
#        and column.humidity = (optional = true and type = "float" and value = "bring [payload][humidity]")
#        and column.temperature = (optional = true and type = "float" and value = "bring [payload][temperature]")
#        and column.temperatureUnit = (optional = true and type = "string" and value = "bring [payload][temperatureUnit]")
#        and column.switch = (optional = true and type = "bool" and value = "bring [payload][switch]")
#        and column.adcIn = (optional = true and type = "string" and value = "bring [payload][adcIn]")
#        and column.adcMax  = (optional = true and type = "string" and value = "bring [payload][adcMax]")
#        and column.rs485 = (optional = true and type = "string" and value = "bring [payload][rs485]")
#        and column.co2value  = (optional = true and type = "float" and value = "bring [payload][co2Value]")
#        and column.trackingId = (optional = true and type = "int" and value = "bring [trackingId]")
#        and column.num_hops = (type = "int" and value = "bring [numHops]")
#        and column.max_hops = (type = "int" and value = "bring [maxHops]")
#        and column.id = (type = "int" and value = "bring [id]")
# )>
#----------------------------------------------------------------------------------------------------------------------#
# process deployment-scripts/demo-scripts/winnio_kafka.al

on error ignore

:set-params:
kafka_ip = 135.225.106.191
kafka_port = 9092
kafka_reset = earliest
topic = pilback.data

:run-policy:
on error cal kafka-error
<run kafka consumer where
    ip = !kafka_ip and
    port = !kafka_port and
    reset = !kafka_reset and
    topic = (name=!topic and policy=!policy_id)
>

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

:kafka-error:
print "Failed to execute Kafka consumer service"
goto terminate-scripts