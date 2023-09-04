FROM alpine:3.18

LABEL maintainer="Serialt"

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk add --no-cache sudo git xfce4 faenza-icon-theme bash python3 tigervnc xfce4-terminal  wqy-zenhei firefox  wget novnc websockify \
    && adduser -h /home/alpine -s /bin/bash -S -D alpine && echo -e "alpine\nalpine" | passwd alpine \
    && echo 'alpine ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    
RUN  echo -en "\nexport LC_ALL=zh_CN.UTF-8\nexport LANG=zh_CN.UTF-8\nexport LANGUAGE=zh_CN:zh" >> /etc/profile


RUN ln -s /usr/share/novnc/vnc_lite.html /usr/share/novnc/index.html

USER alpine
WORKDIR /home/alpine

RUN mkdir -p /home/alpine/.vnc \
    && echo -e "-Securitytypes=none" > /home/alpine/.vnc/config \
    && echo -e "#!/bin/bash\nstartxfce4 &" > /home/alpine/.vnc/xstartup \
    && echo -e "alpine\nalpine\nn\n" | vncpasswd

USER root

RUN echo '\
#!/bin/bash \
/usr/bin/vncserver :99 2>&1 | sed  "s/^/[Xtigervnc ] /" & \
sleep 1 & \
/usr/bin/novnc_server --vnc localhost:5999 2>&1 | sed "s/^/[noVNC     ] /"'\
>/entry.sh

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

USER alpine

ENTRYPOINT [ "/bin/bash", "/entry.sh" ]
