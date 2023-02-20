#
#====================================================================
# GitHub Action Docker image
#
#
# Base image
#
FROM python:3.10-slim
#
#====================================================================
# System Initialization
#
RUN apt-get update -y \
  && apt-get upgrade -y \
  && rm -rf /var/lib/apt/lists/*
#
#====================================================================
# Python Setup
#
COPY ./requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt
#
# Action entrypoint
#
COPY ./action.py /usr/local/bin/zimagi-action
ENTRYPOINT [ "zimagi-action" ]
