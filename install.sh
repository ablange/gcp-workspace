##############################################################################
#
#        Configure Ubuntu Desktop on GCP
#		 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Dependencies:
#     (1) Google Cloud Platform (account & project)
#     (2) VNC Viewer (https://www.realvnc.com/en/connect/download/viewer/)
#
##############################################################################
# Install gcloud on local
cd ~/repos/
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-325.0.0-darwin-x86_64.tar.gz;
tar -xf google-cloud-sdk-325.0.0-darwin-x86_64.tar.gz;
rm google-cloud-sdk-325.0.0-darwin-x86_64.tar.gz;
./google-cloud-sdk/install.sh;
./google-cloud-sdk/bin/gcloud init;
gcloud components install alpha;
gcloud components install beta;

# Set context
gcloud config set run/region us-central1;
gcloud config set core/project andrewblange;

# Create Ubuntu VM
gcloud beta compute instances create andrewblange-workspace \
    --project=andrewblange \
    --zone=us-central1-a \
    --machine-type=e2-medium \
    --subnet=default \
    --network-tier=PREMIUM \
    --maintenance-policy=MIGRATE \
    --service-account=700881912045-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --tags=http-server,https-server \
    --image=ubuntu-1604-xenial-v20210119 \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=30GB \
    --boot-disk-type=pd-ssd \
    --boot-disk-device-name=instance-name \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --reservation-affinity=any;

#########################################
# SSH into Ubuntu VM
#########################################
# First complete the following steps in the Google Console UI:
#    'Compute' > 'VMs' > Select VM > 'SSH' > 'Open in Browser Window'
#
# Then run steps 1-6 in the VM:
# (1) Install dependencies
sudo apt-get update;
sudo apt-get upgrade;
sudo apt-get install gnome-shell;
sudo apt-get install ubuntu-gnome-desktop;
sudo apt-get install autocutsel;
sudo apt-get install gnome-core;
sudo apt-get install gnome-panel;
sudo apt-get install gnome-themes-standard;

# (2) Install VNC Server
sudo apt-get install tightvncserver;
touch ~/.Xresources;

# (3) Launch VNC Server (create password if first time)
tightvncserver

# (4) Edit VNC startup script
vim /home/andrew_lange93/.vnc/xstartup;
"""
#!/bin/sh
autocutsel -fork
xrdb $HOME/.Xresources
xsetroot -solid grey
export XKL_XMODMAP_DISABLE=1
export XDG_CURRENT_DESKTOP="GNOME-Flashback:Unity"
export XDG_MENU_PREFIX="gnome-flashback-"
unset DBUS_SESSION_BUS_ADDRESS
gnome-session --session=gnome-flashback-metacity --disable-acceleration-check --debug &
"""

# (5) Kill server (must restart to run startup script)
vncserver -kill :1;

# (6) Start VNC server & set resolution size
vncserver -geometry 1024x640;

# (optional)
exit

#########################################
# Run the following in Local
#########################################
# SSH into VM on port 5091
gcloud compute ssh andrewblange-workspace \
    --project andrewblange \
    --zone us-central1-a \
    --ssh-flag "-L 5901:localhost:5901"

# Launch VNC Viewer
# Enter URL: localhost:5901
# Enter password that was previously created by tightvncserver


#########################################
# Useful
#########################################
# List VNC instances
ps -ef | grep vnc;

# Kill a VNC instance
vncserver -kill :<instance-number>;
vncserver -kill :1;

# Start a new VNC instance & set resolution size
# vncserver -geometry 1024x640;   # small
vncserver -geometry 1680x1050;  # medium
# vncserver -geometry 2560x1540;  # large
