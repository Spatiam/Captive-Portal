<html>
<style>

html{
    font-family: 'Helvetica', 'Arial', sans-serif;
    width: 100%;
    height:100%;
    margin-right:auto;
    margin-left: auto;
}

body{
    width:100%;
    height:100%;
    background-color:#DDD;
}

.header {
    margin-bottom: 4rem;
    padding-top: 2.5rem;
    width:100%;
    text-align: center;
}

.header_image {
    width: 45%;
}

.broadcast_area {
    color: white;
    background-color: rgb(244,30,36);
    padding: 2rem;
    margin: 3rem;
    margin-bottom: 4rem;
}

.broadcast_header {
    display: flex;
}
.broadcast_image {
    height: 7rem;
    width: auto;
}

.messaging_area {
    box-shadow: 0 0 10px rgb(25, 69, 114);
    color: white;
    background-color: rgb(39, 119, 200);
    border-radius: 2rem;
    padding: 2rem;
    margin: 3rem;
    font-family: inherit !important;
}

.messaging_header {
    display: flex;
}
.messaging_image {
    height: 7rem;
    width: auto;
}

.messaging_form {
    padding-top: 1.5rem;
}

input[type=text] {
    align: top;
    width: 100%;
    font-size: 2.5rem;
    padding: 1rem;
    margin-bottom: 1.5rem;
    border: none;
    border-radius: 1rem;
    -webkit-appearance: none;
}

.messaging_message {
    align: top;
    width: 100%;
    font-size: 2.5rem;
    padding: 1rem;
    margin-bottom: 1.5rem;
    border: none;
    border-radius: 1rem;
    -webkit-appearance: none;
    font-family: inherit;
}

input[type=submit] {
    width: 100%;
    color: white;
    font-size: 2.5rem;
    padding: 1rem;
    background-color: rgba(0, 0, 0, 0);
    border: 0.3rem solid white;
    border-radius: 10px;
    -webkit-appearance: none;
    font-weight: bold;
}

.android_area {
    box-shadow: 0 0 10px rgb(8, 115, 71);
    color: white;
    background-color: rgb(8, 197, 118);
    border-radius: 2rem;
    padding: 2rem;
    margin: 3rem;
    margin-top: 4rem;
}

.android_header {
    display: flex;
}
.android_image {
    height: 7rem;
    width: auto;
}

.download_app_button {
    margin-top: 1.5rem;
    margin-bottom: 1.5rem;
    width: 100%;
    color: white;
    font-size: 2.5rem;
    padding: 1rem;
    background-color: rgba(0, 0, 0, 0);
    border: 0.3rem solid white;
    border-radius: 10px;
    -webkit-appearance: none;
    font-weight: bold;
}

h1 {
    padding: 0;
    margin: 0;
    height: 7rem;
    vertical-align: middle;
    padding-top: 1.5rem;
    padding-left: 1.5rem;
    font-size: 4rem;
}

p {
    font-size: 2.5rem;
    padding: 0;
    margin: 0;
}

.footer {
    padding-top: 4rem;
    padding-bottom: 3rem;
    font-size: 2.5rem;
    font-weight: 0.1rem !important;
    text-align: center;
}

/* For laptops and tablets */
@media only screen and (min-width: 1000px) {
    html{
        max-width: 50%;
    }

    h1 {
        padding-top: 2.5rem;
        font-size: 2rem;
    }

    p {
        font-size: 1.5rem;
    }
    input[type=text] {
        font-size: 1.5em;
    }

    .messaging_message {
        font-size: 1.5rem;
    }

    input[type=submit] {
        font-size: 1.5rem;
    }

    .download_app_button {
        font-size: 1.5rem;
    }
}


</style>
<body>
<div class="broadcast_area">
    <div class="broadcast_header">
        <img class="broadcast_image" src="/images/warning_icon.png" alt="warning" >
        <h1>Broadcast Message</h1>
    </div>
    <p>Your area is experiencing intermittent, or no connectivity due to an emergency. 
        Use this portal to communicate with a central server and report 
        your area’s state and needs</p>
</div>
<div class="messaging_area">
    <div class="messaging_header">
        <img class="messaging_image" src="/images/messaging_icon.png" alt="message" >
        <h1>Messaging Service</h1>
    </div>
    <p>Your message will reach the control center, including your current location</p>
    <form class="messaging_form" action="submit.php" method="post">
        <input type="text" name="uname" placeholder="Name" >
        <!-- Input changed to textarea for message. Change 'maxlength' attribute to limit character count -->
        <textarea class="messaging_message" rows="4" maxlength="1000" type="text" name="password" placeholder="Message"></textarea>
        <input type="submit" value="Submit" >
</form>
</div>

<div class="android_area">
    <div class="android_header">
        <img class="android_image" src="/images/android_icon.png" alt="android" >
        <h1>Android App</h1>
    </div>
    <p> To send files, photos, and comminicate with other android responders
    </p>
    <a href="download.php?file=DTN.apk">
        <button class="download_app_button">Download</button>
    </a>

    <p>**To Use this download link, connect to the network and navigate to <u>www.abc.com</u> in your browser</p>
</div>
<div class="footer">
    <img class="header_image" src="/images/spatiam_logo.png" alt="Spatiam" >
    <br><br>
    <p>Spatiam Corporation © 2021</p>
</div>
</body>
</html>