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
# Action entrypoint
#
COPY ./lib /usr/local/lib/action
RUN ln -s /usr/local/lib/action/main.py /usr/local/bin/zimagi-action

ENTRYPOINT [ "zimagi-action" ]
#
#====================================================================
# Python Setup
#
COPY ./requirements.txt .
COPY ./requirements.client.txt .

RUN pip3 install --no-cache-dir -r requirements.txt
RUN [ -f /usr/local/lib/action/requirements.txt ] || pip3 install --no-cache-dir -r requirements.client.txt
RUN [ ! -f /usr/local/lib/action/requirements.txt ] || pip3 install --no-cache-dir -r /usr/local/lib/action/requirements.txt
