<?php
$roomid = $_GET['room'];
$ventid = $_GET['vent'];
$setpoint = $_GET['setpoint'];

$logStr = date(DATE_RFC2822);
$logStr .= ": Setting room " . $roomid;
if ($ventid != '')
    $logStr .= ", vent " . $ventid;
$logStr .= " to setpoint " . $setpoint . "\n";
error_log($logStr, 3, "access.log");

$room = Array();
$room['id'] = $roomid;
$room['temp'] = '73';
#$room['vents'] = Array();
#for ($vid=0; $vid < 3; $vid++) {
#    $idStr = (string)$vid;
#    $vent = Array();
#    $vent['id'] = $idStr;
#    if ($ventid == $idStr or $ventid == '')
#        $vent['state'] = $setpoint;
#    else 
#        $vent['state'] = '50';
#    $room['vents'][$idStr] = $vent;
#}
$room['state'] = $setpoint;

// Send command to vent

// If the vent is closing, turn off the unit
#if ($setpoint == '0')
    // Turn unit off

#if ($ventid=='') {
#echo json_encode($room);
echo "Done";
#}
#else {
#    echo json_encode($room['vents'][$ventid]);
#}
?>
