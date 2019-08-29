# Start Yocto - Add a New Recipe 

이 문서에서는 [지난 문서 ](https://hcyang1012.github.io/blog/1_bbb/1_YOCTO_HOWTO/0_Start_20190828.html) 에 이어 새로운 어플리케이션 하나를 빌드에 포함시키는 방법에 대해 알아보자. 여기서는 [nInavders](http://ninvaders.sourceforge.net/) 라는 게임을 예제로 사용할 것이다. 

이 문서 역시 [Bootlin](https://bootlin.com/)의 [Yocto Project  and OpenEmbedded development course 의 자료](https://bootlin.com/doc/training/yocto/)를 참고하여 작성하였다. 자세한 설명은 자료를 참고하는 것을 추천한다.

## 맛보기 : nInvaders 

[nInavders](http://ninvaders.sourceforge.net/)는 고전 게임인 invaders를 콘솔에서 즐길 수 있게 ncurses 기반으로 개발한 버전이다.  프로젝트 홈페이지에 가면 소스코드를 다운받을 수 있으며, 간단히 다음과 같이 make 명령 만으로 빌드가 가능하다. (단 ncurses 라이브러리가 설치되어 있어야 한다.)

```bash
$  wget https://jaist.dl.sourceforge.net/project/ninvaders/ninvaders/0.1.1/ninvaders-0.1.1.tar.gz
$  tar xvf ninvaders-0.1.1.tar.gz 
$  cd ninvaders-0.1.1 
$  ninvaders-0.1.1 make
```
빌드가 완료되면 nInvaders라는 파일을 통해 게임을 즐길 수 있다. 이번 문서의 목표는 Yocto 를 이용해 이미지를 빌드 시 소스코드 다운로드부터 빌드까지 자동으로 이루어지도록 하고, 최종적으로는 생성된 실행파일인 nInvaders 파일을 타겟(Beaglebone Black) 의 /usr/bin/ 에 옮겨지도록 하는 것이다.

## Recipe 추가 

### Recipe 개요
Recipe는 하나의 Software 가 빌드되어지도록 하는 Task들의 모음이다. 예를 들어, Linux Kernel을 빌드하기 위해서는 다음과 같은 Task들이 필요할 것이다.

- Source Code Download 
- Toolchain Download
- Patch
- Compile
- Image Install

Yocto에서는 위와 같이 소프트웨어를 빌드하기위해 수행되어져야 하는 각각의 논리적인 행동들이 Task로 정의된다. Recipe는 이러한 Task들의 집합으로, Yocto는 Recipe에 있는 Task들을 정의된 대로 순서대로 실행시켜 개발자가 원하는 하나의 소프트웨어가 이미지에 포함되어질 수 있도록 해 준다.

Recipe를 만들 때 개발자가 자체적으로 Task들을 하나 하나 정의하고 실행 순서까지 정의 할 수 있지만, 다음과 같이 [기본적인 Task들](https://www.yoctoproject.org/docs/2.7.1/ref-manual/ref-manual.html#normal-recipe-build-tasks)이 주어지기 때문에 각각에 용도에 맞추어 수행해야 할 내용들만 채워주면 쉽게 Recipe를 구성할 수 있다.

-  do_fetch : 소스코드를 외부에서 가져올 때  수행되어야 할 내용들을 정의.
-  do_unpack : 소스코드가 압축파일인 경우 압축을 풀 때  수행되어야 할 내용들을 정의.
-  do_patch : 소스코드를 다운로드 받은 후 패치를 적용하여야 할 때 수행되어야 할 내용들을 정의.
-  do_configure : 컴파일 전 빌드 환경 configuration을 할 때 수행되어야 할 내용들을 정의.
-  do_compile : 컴파일 시 수행해야 할 내용들을 정의.
-  do_install : 컴파일 후 생성물을 원하는 위치에 복사하고자 할 때 수행되어야 할 내용들을 정의
-  do_package : 빌드 산출물에서 패키지를 생성할 시 수행되어야 할 내용들을 정의
-  do_rootfs : rootfs를 구성할 때 수행되어야 할 내용들을 정의

### 디렉토리 추가 및 구성

우선 원하는 Layer에 nInvaders의 Recipe를 추가해 주어야 한다. 보통은 Custum Layer를 생성 후 생성한 Layer에 Recipe를 추가하지만, 여기서는 Recipe를 만들고 추가하는 방법을 정리하는 것이 목적이므로 Poky에 추가해 보자.

```bash
$ cd $HOME/yocto-labs/poky/meta/recipes-extended
$ mkdir  ninvaders
$ cd ninvaders
```

Yocto에서 Recipe는 어플리케이션의 버전별로 관리가 가능하다. 이를 위해 Yocto에서는 Recipe를 만들 때 버전에 관계 없이 공통으로 적용되는 Task들이 정의되어 있는 .inc파일과 버전에 따라 다르게 동작해야 하는 Task들이 정의되는 Recipe 파일로 분리해서 Recipe를 정의하는 것이 가능하다. ninavders의 최신(마지막) 버전은 0.1.1이므로 다음과 같이 inc파일과 0.1.1 버전에 대한 Recipe 파일을 ninvaders 디렉토리 안에 만들자.

```bash
$ touch ninvaders.inc
$ touch ninvaders_0.1.1.bb
```

## 빌드 스크립트 작성

사실 ninvaders는 버전도 몇 개 존재하지 않고, 작은 규모의 프로젝트이기 때문에 버전 별로 빌드 방법이 크게 다르지 않다. 따라서 .inc파일에 빌드 방법을 작성해도 무방하다. 다음과 같이 invaders.inc 파일의 내용을 채워주자.

---
``` bash
$ vi ninvadersi.inc
```
```bash
SUMMARY = "A helloworld exmple for nInvaider"
HOMEPAGE = "http://ninvaders.sourceforge.net/"
SECTION = "base"

SRC_URI = "https://jaist.dl.sourceforge.net/project/ninvaders/ninvaders/0.1.1/ninvaders-0.1.1.tar.gz"
DEPENDS = "ncurses"

do_compile(){
        oe_runmake 'CC=${CC}' 
}

do_install(){
        install -d ${D}${bindir}
        install -m 0755 nInvaders ${D}${bindir}
}
```
---

내용들을 간단히 훑어보자.

### 기본 정보 
- SUMMARY / HOMEPAGE : Recipe에 대한 요약 정보들을 기술
- SECTION : 이 패키지가 속해있는 분류를 정의한다. 여기서는 중요하게 다루는 정보가 아니라 base로 작성해 두었다.
- SRC_URI : 소스코드의 주소. bitbake는 SRC_URI에서 명시되어 있는 소스코드를 다운로드받아 작업 디렉토리에 압축을 푼다.
- DEPENDS : 의존성 있는 라이브러리를 추가한다. 여기서는 ncurses 라이브러리를 추가하였다.

### do_compile()
do_compile() 함수는 compile시에 어떤 작업을 수행해야 할 지 기술하는 함수이다. 여기서는 Yocto가 제공하는 함수인 oe_runmake를 사용하였다.  현 상태에서는 make를 실행시키는 것과 동일하다.

단, 빌드 시 크로스 컴파일이 되어야 하기 때문에 CC 환경 변수를 make에 위와 같이 적용시켰다. 참고하도록 하자.

### do_install()
do_install 함수에서는 rootfs의 /usr/bin/디렉토리를 생성시킨 후 거기에 nInvaders라는 실행 파일이 복사되도록 기술하였다.


## 버전 별 Recipe 작성

ninvaders.inc 파일은 버전에 관계 없이 공통적으로 수행되는 작업들을 정의해 놓은 파일에 불과하기 때문에 이 파일을 사용하기 위해서는 다음과 같이 실제 Recipe 파일인 ninvaders_0.1.1.bb 파일이 ninvaders.inc 파일을 포함하도록 해야 한다.

---
``` bash
$ vi ninvaders_0.1.1.bb 
```
```bash
require ninvaders.inc

LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://README;md5=62f2ab9779d8f2b6bce96bdbad303623"
SRC_URI[md5sum] = "97b2c3fb082241ab5c56ab728522622b"
```

---

제일 첫 줄에는 앞서 만들어 둔 ninvaders.inc 파일을 포함시키기 위해 require문으로 파일을 포함시켰다.

Yocto로 Recipe를 빌드할 때에는 반드시 라이선스와 라이선스 파일 그리고 라이선스/소스코드에 대한 Checksum을 지정해 주어야 한다.

다만, nInvaders 는 라이선스 관련 파일이 존재하지 않기 때문에 이 예제에서는 소스코드에 포함된 README 파일을 대신 사용하였다. 

README 파일 및 소스코드(ninvaders-0.1.1.tar.gz) 의 Checksum은 MD5 를 사용했으며, 다음과 같이 미리 받아놓은 소스코드에서 계산하여 추출하였다.

---
```bash
# 소스코드 MD5 (SRC_URI[md5sum]) 계산
$ md5sum ninvaders-0.1.1.tar.gz 
97b2c3fb082241ab5c56ab728522622b  ninvaders-0.1.1.tar.gz
```

```bash
# 라이선스 파일(README) MD5 게산 
# LIC_FILES_CHKSUM = "file://README;md5=62f2ab9779d8f2b6bce96bdbad303623"
$ md5sum README 
62f2ab9779d8f2b6bce96bdbad303623  README
```
---


## Test Building Recipe

Layer에 Recipe를 포함시켜 이미지 전체를 빌드해 보기 전에 새로 만든 ninvaders의 빌드가 질 되는지 확인해 보자. 다음과 같은 명령어로 ninvaders만 빌드 테스트가 가능하다.

```bash
$ MACHINE="beaglebone" bitbake ninvaders
```

특별한 문제가 발생하지 않는다면 Layer에 ninvaders 패키지를 포함시켜 빌드해 보자.

---
```bash
$ vi conf/local.conf
```

build/local.conf 파일 아래에 다음과 같이 추가하자.

```bash
# conf/local.conf
# 앞 내용 생략
# 맨 끝에 다음과 같이 추가한다.
IMAGE_INSTALL_append = " ninvaders"
```

편집이 끝났으면 이미지 빌드가 정상적으로 되는지 확인해 보자

```bash
$ MACHINE=beaglebone bitbake core-image-minimal
```

---

완성된 rootfs 를 SD카드에 복사 후 부틱시키면 다음과 같이 /usr/bin 아래에 nInvaders 라는 파일이 생성된 것을 확인할 수 있고, 실행도 가능하다.

---

```bash
root@beaglebone:/bin# ls -al /usr/bin/nInvaders 
-rwxr-xr-x    1 root     root         46632 Aug 28 04:49 /usr/bin/nInvaders
```

```bash
root@beaglebone:/bin# nInvaders

                            ____                 __          
                      ___  /  _/__ _  _____  ___/ /__ _______
                     / _ \_/ // _ \ |/ / _ `/ _  / -_) __(_-<
                    /_//_/___/_//_/___/\_,_/\_,_/\__/_/ /___/




                                   <o o> = 500
                                              
                                   ,^,   = 200
                                              
                                   _O-   = 150
                                              
                                   -o-   = 100







                              Press SPACE to start

```
---


## 정리

이번 문서에서는 Layer에 Recipe를 추가하는 방법에 대해 정리해 보았다. 예제로서 nInvader라는 간단한 콘솔용 프로그램을 이용하였고, Recipe에 소스코드 다운로드 방법/ 컴파일방법 / 설치 방법 등을 기술하여 Yocto가 nInvader를 빌드/설치할 수 있도록 했다. 마지막으로 Recipe로 만들어진 패키지를 Layer에 포함시켜 만들어진 이미지를 Beaglebone Black에서 직접 테스트 해 보았다.

일단은 동작하는 예제를 만들어 봤지만 몇가지 추가로 확인해 봐야 할 것들이 있다. 먼저, Recipe만 단독으로 빌드 하였을 때 에러가 없다는 것 외에는 정상적으로 만들어졌는지 확인하는 방법을 찾아봐야겠다. 그리고 Recipe를 만들면서 사용한 몇 가지 환경변수들이 어떤 의미를 가지는지도 구체적으로 확인해 봐야겠다.

또한 이번 예제에서는 Recipe를 다뤄본다는 의미에서 Poky에 Recipe를 직접 추가하여 테스트 했지만 실제로는 Custom Layer를 추가한 후 여기에 Recipe를 추가하는 방식으로 구성 하는 것이 보통이다. 이에 다음에는 Layer를 구성하는 방법에 대해 알아보자.

