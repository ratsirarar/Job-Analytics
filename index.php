<?php 

$data = array(); // define array
set_time_limit(120);
exec('index.exe', $data, $ret); // execute command, output is array
if ($ret == 0 && count($data)!=0) { // check status code. if successful
	$result=(string) $data[0];
	$result=preg_replace('/=>/',':',$result);
	header('Content-type: application/json');
	echo $result;
} else {
echo "Error in command"; // if unsuccessful display error
}



?>