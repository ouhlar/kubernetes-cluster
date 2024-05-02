# Use the official Ubuntu base image
FROM ubuntu:latest

# Update the package repository and install OpenSSH Server
RUN apt-get update && apt-get install -y openssh-server

# Create the SSH directory and generate SSH host keys
RUN mkdir /var/run/sshd
RUN ssh-keygen -A

# Create a user for SSH access (replace 'username' and 'password' with your desired user and password)
RUN useradd -m -s /bin/bash username
RUN echo 'username:password' | chpasswd

# Optionally change the SSH settings (e.g., disable root login)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Expose the SSH port
EXPOSE 22

# Start the SSH daemon in the foreground so that the container keeps running
CMD ["/usr/sbin/sshd", "-D"]