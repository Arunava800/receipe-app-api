#Steps that docker needs to build an image
# 1. Define the name of the image that is being used.
# 2. from image
# 3. Name of the image: Name of the tag- it ensures that we are using python 3.9 and we
# are using the alpine version
FROM python:3.9-alpine3.13
# Specify the maintainer, maintained by whom.
LABEL maintainer="arunava"

# It tells docker that we don't want to buffer the output, the output is directly
#printed out to the console, which prevents any delays of the messages from our python
#running application to screen
ENV PYTHONUNBUFFERED 1
#Copy the requirements.txt file from our local machine to /tmp/requirements.txt
#Copy the app directory that contains our django app
#We set the workdir, it is the working directory and is the default from the commands
# are being runned from. We are keeping it in a location where the django project is being
#synced to, so that when we run the command we don't have to specify the full path
#Expose 8000 exposes the port 8000 from our container to our machine when we run the container
#It allows us to access the port 8000 in the container running from our image.
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

#We run the run command which runs a command on the alpine image that we are using when we are
#building our image. When RUN command is inserted for every line, it creates new image layers
#for every single commands we run.
#The first line creates a virtual enviroment that we are going to use to store the dependencies.
#The second line defines the full path of the virtual environment, by doing py/bin/pip, it
#upgrades the python manager inside the virtual environment.
#The third line is used to install the package requirements inside the docker image.
#The fourth line removes the tmp directory, since we don't want any extra dependencies in side
#our image once it is created. It is best practice to keep docker images as light weight as
#possible. So, if there are some packages are not required, they are removed as part of the
#build process.
#The adduser block calls the adduser command which adds a new user inside of our image.
#The reason to do this, as it is the best practice to not use the root user. Therefore, if the
#adduser is not installed, then the only user that is available in the alpine is the root user.
#The root user is the user which has the full access to write, delete and update on the server
#DON'T RUN THE APPLICATION USING THE ROOT USER.This is because, if the application gets
#compromised, then the attacker has the full access of that docker container.
#On the other hand, if the adduser is added, then if the application gets compromised, then
#the attacker will able to do, only the functions that are accesible for the defined user.
#-disalbe-password: signifies we are not going to use the password to log on to the container
#-no-create-Home: does not create home directory for the user.
#django-user: it is the name of the user.
ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
      then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser \
    --disabled-password \
    --no-create-home\
    django-user


#The ENV line is use to update the enviroment variable inside the image and the path environment \
# variale is being updated here.
ENV PATH="/py/bin:$PATH"

#This line denotes the last line of the docker file and specifies the user that we are switching
#to. The container that is being used in the image will use the last user that the image switch
#to.
USER django-user
