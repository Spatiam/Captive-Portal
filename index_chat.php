<!DOCTYPE html>
<html>
<head>
  <title>PHP DataStore</title>
</head>
<body>
  <form method="post">
    Message:<br>
    <input type="text" name="textdata"><br>
    <input type="submit" name="submit">
    
  </form>
</body>
</html>-
<?php
              
if(isset($_POST['textdata']))
{
$data=$_POST['textdata'];
$fp = fopen('data.txt', 'a');
fwrite($fp, $data);
fclose($fp);
}
?>