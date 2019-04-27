## API

### Status 

#### Request
/status

#### Response format
```json
{  
   "status":{  
      "device_id":56666541,
      "device_type":"socket",
      "device_name":"desk",
      "relays":[  
         {  
            "id":1,
            "status":0,
            "name":"relay"
         },
         {  
            "id":2,
            "status":0,
            "name":""
         }
      ],
      "uptime":3498,
      "heap":20528,
      "wifi_info":{  
         "connection_timepoint":1440,
         "reconnect_count":2,
         "rssi":-70,
         "last_reason_reconnection":"BEACON_TIMEOUT"
      },
      "gpio_info":{  
         "last_change":"Default"
      }
   }
}
```

### Action

#### Request

Request | Description
------------ | -------------
/action/on/{relay_index} |
/action/off/{relay_index} |
/action/inversion/{relay_index} |
/action/all_off |
/action/all_on |

### Set

#### Request
Request | Description
------------ | -------------
/set/station/{ssid}/{password} |
/set/device_type/{type_name} |
/set/device_id/{device_id} |
/set/device_name/{device_name} |
/set/relay_name/{relay_index}/{relay_name} |



