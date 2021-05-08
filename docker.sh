# !bin/bash

container_name=$1
image_name=$1

container_temp=$(docker ps | grep ${container_name}|awk '{print $1}')
if [ ${#container_temp} != 0 ] ; then
   echo "living container is existing"
   docker rm -f ${container_temp}
   if [ $? == 0 ] ; then
      echo "---------------------------------"
      echo "container remove success!!"
      echo "---------------------------------"
   fi
else
  echo "---------------------------------"
  echo "no container is living!"
  echo "---------------------------------"

fi

image_temp=$(docker images | grep ${image_name} | awk '{print $3}')
if [ ${#image_temp} != 0 ] ; then
   echo "-----------------------------------"
   echo "image is existing!!"
   echo "-----------------------------------"
   docker rmi -f ${image_temp}
   if [ $? == 0 ] ; then
      echo "---------------------------------"
      echo "image remove success!!"
      echo "---------------------------------"
   fi
else 
  echo "----------------------------------"
  echo "no image is exist!"
  echo "----------------------------------"
fi
echo "-------------------------------------"
echo "waiting ---------------------"
echo "-------------------------------------"
sleep 10
   
