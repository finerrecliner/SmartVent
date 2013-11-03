<?php
$roomid = $_POST['room'];
$ventid = $_POST['vent'];

$logStr = date(DATE_RFC2822);
$logStr .= ": Querying room " . $roomid;
if ($ventid != '')
    $logStr .= ", vent " . $ventid;
$logStr .= "\n";
error_log($logStr, 3, "access.log");

$room = Array();
$room['id'] = $roomid;
$room['temp'] = '69';
#$room['vents'] = Array();
#for ($vid=0; $vid < 3; $vid++) {
#    $idStr = (string)$vid;
#    $vent = Array();
#    $vent['id'] = $idStr;
#    $vent['state'] = '50';
#    $room['vents'][$idStr] = $vent;
#}
$room['state'] = '50'; 
#if ($ventid=='') {
echo json_encode($room);
#}
#else {
#    echo json_encode($room['vents'][$ventid]);
#}
?>
