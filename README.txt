Isaac Smead
818629741
CS646 Final Project
https://github.com/isaacsmead/flashcloud

SETUP -- (to get flashair on your wireless lan)
1. put sd card in computer, should mount as FLASHAIR

2. open CONFIG file mount/FLASHAIR/SD_WLAN/CONFIG in your favorite text editor
   Note: /SD_WLAN is hidding in finder, so command line is easiest

3. Edit the following fields:

    APPSSID=your_wifi_name
    APPNETWORKKEY=your_wifi_pass
    IP_Address=192.168.1.50 (or whatever you want for your subnet)
    Subnet_Mask=255.255.255.0 (your subnet mask)
    Default_Gateway=192.168.1.1 (your default gateway)

    Note:  With the settings above you will know the IP of flashair, if your router
    supports NetBIOS or TCP/IP and Bonjour you can enable DHCP and flashair should
    be discoverable as flashair1 (DHCP_Enabled=YES)
    Reference: https://flashair-developers.com/en/documents/api/config/

4.  Unmount and remove.

5.  Put flashair in camera or back in computer.  You can test it on you network by
    going to the IP in a browser windw.  It will only be connected when the flashair
    has power so you might want to adjust your cameras auto-off.  During development
    I just left it plugged into my desktop and had a continuous connection.  Not sure
    about laptops, i've read some cut power when not reading SD cards.

USING THE APP
1.  when app opens navigate to settings screen

2.  change Flashair Settings -> Host to what ever IP you chose in flashair CONFIG

3.  select Save then Back

4.  select back again to trigger refresh of data (i need to add code to make it automatic)

5.  you can browse directories and images will apear in dirs that have them.  you can select
    multiple images and delete or upload.  Successful upload will also trigger delete

6.  you can see uploaded images at: https://76.88.58.107/nextcloud
    user: cs646
    password: cs646test
    the server (raspberry pi) is pretty slow and you'll get a security warning because it uses self-signed cert

7.  High quality photos take a while to upload.  There are some random pics in the small-files directory
    that will upload faster.  If you manually copy images to the flahair they need to be JPEG with thumbnail
    imbedded in the EXIF.  Photos taken with digital camera should be fine so long as camera is set to JPEG format.

KNOWN ISSUES
1.  I need to add an event loop to check for connection/updates etc.  For now the only way a data
    fetch is triggered is with back button or clicking directory.

2.  There is no stoppoing user input while reqests are pending so rapid button pushes just keep
    queuing up requests.  This is especially a problem if the flashair is not online because the
    request timeout is long so it takes a while for the error message to come back

3.  I ran into some issues with a certian image causing the flashir itself to crash when download requested.
    Same behavious via browser to the flashair.  I removed the troublesome image and haven't seen
    the problem since.

4.  Occasionally an image(s) wont upload, i tracked it down to a because resource locked code, probably
    because my nextcloud uses mysql.  This happend to me when uploading many photos at once.
    Workaround is to change destination directory.

5.  Upload fails if destination directory doesn't exist in nextcloud.  I need to add code to check for
    directory and create it if necessary.


SHORTCOMINGS
I spent a lot of time spinning my wheels figuring out how all the moving parts worked and didn't get as much
functionality done as planned.  One major thing I wanted to do was display full screen images and
have gesture actions like tinder.  Swipe left to delete, right to send to cloud.

The real-world issue with my app is that no normal user would want to modify the config file
for the flashair.  The app could take care of all these things, but to make it really smooth
it would require writing some lua scripts for the flashair itself.  It's something I'll probably
do in the future because it would be great to walk into the house with a camera full of pictures and
have everything push to my cloud by just turning on the camera.

The flashair has hotspot mode, where it hosts its own wireless network.  Theoretically in this mode
my app could pass photos from flashair to the cloud via the phone's LTE connection, but I was never able to
get it to work.  I read on some forums that LTE data should be enabled if connected to wifi using a static IP
and no DNS, but no luck.  I'm wondering if was possible on older versions of IOS, but maybe WiFi assist is
interfering somehow.

Some other things I would do before "shipping".
- Busy indicators when waiting on network
- More robust/desciptive alert system
- use keychain to store nextcloud credentials
- check input fields, immediate feedback for nextcloud login
- pretty colors

REFERENCE
  3rd party libs
   - ALamofire
   - AlamofireImage
   - Carthage (used to build Alamofire)

  API
  - https://www.flashair-developers.com/en/
  - https://docs.nextcloud.com/server/12/developer_manual/client_apis/WebDAV/index.html





