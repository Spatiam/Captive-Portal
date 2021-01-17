<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>APK Download</title>
<style type="text/css">
    .img-box{
        display: inline-block;
        text-align: center;
        margin: 0 15px;
    }
</style>
</head>
<body>
    <?php
    // Array containing sample image file names
    $images = array("Android.png");
    
    // Loop through array to create image gallery
    foreach($images as $image){
        echo '<div class="img-box">';
            echo '<img src="images/' . $image . '" width="200" alt="' .  pathinfo($image, PATHINFO_FILENAME) .'">';
            echo '<p><a href="download.php?file=data.txt">Download</a></p>';
        echo '</div>';
    }
    ?>
</body>
</html>