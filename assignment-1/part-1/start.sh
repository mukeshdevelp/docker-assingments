#!/bin/bash

# getting the current time in 24hr
current_time=$(date +"%H")


# rotating content based on time
if [ "$current_time" -ge 10 ] && [ "$current_time" -lt 12 ]; then
    message="Hello from Mukesh"
elif [ "$current_time" -ge 16 ] && [ "$current_time" -lt 18 ]; then
    message="Hello from Dev"
else
    message="The website is currently offline"
fi

echo $message
# Generate HTML file
echo "<html><body><h1>$message</h1></body></html>" > /usr/share/nginx/html/index.html

# Start nginx
nginx -g 'daemon off;'

