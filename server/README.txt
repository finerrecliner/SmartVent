vent:
  id
  state
room:
  id
  temp
  vents (array)

Query Interface:
POST variables to query.php:
  room
  vent
If vent is not specified, return array of all vents in room, else return
specified vent only. Results encoded with JSON. Example:

Query room 3:
{"id":"3","temp":"73","vents":[{"id":"0","state":"50"},{"id":"1","state":"50"},{"id":"2","state":"50"}]}
Query room 3, vent 0:
{"id":"0","state":"50"}


Set Interface:
POST variables to set.php:
  room
  vent
  setpoint
If vent is not specified, apply to all vents in that room, else set only the
specified vent. Returns JSON dump of affected objects. Example:

Set room 1, setpoint 50:
{"id":"1","temp":"73","vents":[{"id":"0","state":"50"},{"id":"1","state":"50"},{"id":"2","state":"50"}]}

Set room 1, vent 1, setpoint 100
{"id":"1","state":"100"}
