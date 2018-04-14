#!/bin/sh

echo "DOCKER FOR TERREMOTIBOT: image builder"
echo "--------------------"

# 1. Type nodejs version
echo "Type the version of nodejs to install (e.g. 8.9.1)"
read NODEJS_VERSION

# 2. Type docker image name
echo "Type the name of the docker image to build (e.g. botfactory/docker-for-terremotibot)"
read DOCKER_IMAGE_NAME

# Create Dockerfile
cp Dockerfile.template Dockerfile
sed -i "s/NODEJS_VERSION/$NODEJS_VERSION/g" Dockerfile

# 3. Recap build options, wait for user input to start
echo "Ready to build a docker image $DOCKER_IMAGE_NAME:$NODEJS_VERSION with nodejs v$NODEJS_VERSION"
echo "Press any key to start"
read

# 4. Build
docker build -t $DOCKER_IMAGE_NAME:$NODEJS_VERSION .
if [ $? -ne 0 ]; then
    echo "Error while building Docker image. Abort."
    exit 1
fi

# 5. Ask if user wants to push the image to hub.docker.com
echo "Build complete! Do you want to push the new image to hub.docker.com? (y/n)"
read CHOICE
if [ "$CHOICE" = "n" ]; then
  echo "Ok bye!"
  exit 0
fi

# Removes image after pushing
function clean {
	echo "Do you want to remove the image built? (y/n)"
	read CHOICE
	if [ "$CHOICE" = "y" ]; then
	 	echo "Cleanup"
		docker rmi $DOCKER_IMAGE_NAME:$NODEJS_VERSION
	fi
}

# 5. Ask for login
echo "Please login to hub.docker.com"
docker login
if [ $? -ne 0 ]; then
    echo "Error while trying to login. Abort."
    clean
    exit 1
fi

# 6. Push image
echo "Pushing image $DOCKER_IMAGE_NAME with tag $NODEJS_VERSION to hub.docker.com"
docker push $DOCKER_IMAGE_NAME:$NODEJS_VERSION
if [ $? -ne 0 ]; then
    echo "Error while pushing Docker image. Abort."
    clean
    exit 1
fi

# 7. Cleanup
echo "Image pushed to hub.docker.com! Success!"
clean
exit 0
