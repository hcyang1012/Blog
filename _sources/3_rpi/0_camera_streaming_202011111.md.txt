# Raspberry Pi Camera Web Streaming

라즈베리 파이는 카메라 모듈을 장착하여 사용이 가능하다. 이 카메라로 촬영한 영상을 웹으로 볼 수 있도록 해 보자.

## 카메라 Enable
```
$ sudo raspi-config
# Interfacing Options -> Camera -> Yes -> Finish
$ ls /dev/video0
# Video 0 가 나타나야 한다.
```

## mjpg-streamer 빌드
여기서는 mjpg-streamer를 사용할 것이다. 소스코드를 먼저 빌드하자.
```
# 필요한 패키지 설치
$ sudo apt-get install cmake python-pil python3-pil libjpeg-dev build-essential
# mjpg-streamer 다운로드
$ git clone https://github.com/jacksonliam/mjpg-streamer.git
$ cd mjpg-streamer/mjpg-streamer-experimental
$ make
$ sudo make install
```

## Streaming 시작

```
$ mjpg_streamer -o "output_http.so -p 8090 -w /usr/local/share/mjpg-streamer/www/" -i "input_uvc.so"

```

이후 웹 브라우저에서 "http://<라즈베리파이 IP 주소>:8090" 으로 접속하면 화면을 확인 할 수 있다.