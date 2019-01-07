ffmpeg-omx-rpi-docker
=====================
Slim FFMPEG build created solely to stream video from Raspberry Pi camera module as and HLS stream with hardware h264 encoding (OpenMAX, h264_omx).

Usage
-----
Install HTTP server (any should work):
```bash
sudo apt-get install nginx
```

Create a symbolic link from `/tmp/rpi_cam` to `/var/lib/www/`:
```bash
sudo ln -s /tmp/rpi_cam /var/lib/www
```

If you are streaming from Raspberry PI camera module, first load the V4L2 module:
```bash
sudo modprobe bcm2835-v4l2
```

Then start streaming to `/tmp/rpi_cam` (settings are refined):
```bash
docker run -it --rm --device=/dev/video0 --device=/dev/vchiq -v /tmp/rpi_cam:/tmp/rpi_cam:rw -v /opt/vc/lib:/opt/vc/lib:ro chudsaviet/ffmpeg-omx-rpi-docker:latest ffmpeg -y -f v4l2 -video_size 1280x720 -framerate 24 -i /dev/video0 -vcodec h264_omx -profile:v high -zerocopy 1 -keyint_min 0 -b:v 1024k -flags +cgop -g 24 -f hls -hls_time 1 -hls_flags delete_segments -hls_allow_cache 1 -hls_segment_type fmp4 -hls_list_size 16 -hls_delete_threshold 16 /tmp/rpi_cam/rpi_cam.m3u8
```

Then you can open stream in any supported software (VLC, Safari, hls.js, etc...):
```
http://<raspberry_pi>/rpi_cam.m3u8
```

Performance
-----------
On Raspberry Pi 3b+, I was unable to stream 1080p at 24 fps or 720p on 30 fps.
So the best choise is to stream 720p at 24 fps. As alternative, you can stream 800x600 at 60 fps.
Since encoding is hardware, CPU is not loaded much, meaning you can run additional software like OctoPrint.
Video bitrate is not affecting encoding performance too much, so you can play with it to provide optimal quality.



