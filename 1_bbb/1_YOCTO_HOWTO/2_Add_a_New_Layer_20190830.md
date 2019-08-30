# Start Yocto - 새 Layer 만들고 추가하기

이번 문서에서는 현재 프로젝트에 새로운 Layer를 생성하여 이를 빌드에 포함시키는 방법에 대해 정리해 보겠다.

이 문서 역시 [지난 문서](blog/1_bbb/1_YOCTO_HOWTO/1_Add_A_New_Recipe_20190829.html)에 이어 작업하였으며, [Bootlin](https://bootlin.com/)의 [Yocto Project  and OpenEmbedded development course 의 자료](https://bootlin.com/doc/training/yocto/)를 참고하여 작성되었으니 자세한 설명은 자료를 참고하는 것을 추천한다.

## 새 Layer 추가

직접 Layer를 구성하기 위해 필요한 파일들을 작성하는 것도 가능하지만 Layer 생성을 위한 기본적인 파일들을 자동으로 만들어주는 명령을 제공한다. 다음과 같이 *bitbake-layers create-layers* 명령으로 meta-mylayer 라는 Layer를 생성해 보자.

```bash
$ cd $HOME/yocto-labs/
$ bitbake-layers create-layer meta-mylayer
```

## Recipe 추가

다음으로, Layer에 우리가 원하는 Recipe를 추가해 보자. 여기서는 지난 글에서 만들었던 nInvaders Recipe를 mylayer로 옮길 것이다. 

```bash
$ cd $HOME/yocto-labs/
$ mkdir meta-mylayers/recipes-apps
$ mv poky/meta/recipes-extended/ninvaders meta-mylayer/recipes-apps/
```

그리고 빌드 시 정보를 확인해 보기 위해 생성한 meta-layers 디렉토리를 git repository로 만들어 commit 한 개를 추가해 보자.
```bash
$ cd $HOME/yocto-labs/meta-mylayers
$ git init
$ git add .
$ git commit -m "initial commit"
```

## 생성한 Layer를 빌드에 추가
이제 Layer 자체는 준비가 되었다. 이제 mylayer를 빌드에 포함시킨 후 빌드해 보자.

---
```bash
$ cd $HOME/yocto-labs/build
$ vi conf/bblayers.conf
```

다음과 같이 bblayers.conf 파일의 끝에 meta-mylayers의 절대경로를 포함시키자.

```bash

# $HOME/yocto-labs/build/conf/bblayers.conf

# POKY_BBLAYERS_CONF_VERSION is increased each time build/conf/bblayers.conf
# changes incompatibly
POKY_BBLAYERS_CONF_VERSION = "2"

BBPATH = "${TOPDIR}"
BBFILES ?= ""

# BBLAYERS 환경 변수의 끝에 meta-mylayers의 절대경로를 추가
# /media/hcyang/work/work/bbb/yocto-labs/meta-mylayer
BBLAYERS ?= " \
  /media/hcyang/work/work/bbb/yocto-labs/poky/meta \
  /media/hcyang/work/work/bbb/yocto-labs/poky/meta-poky \
  /media/hcyang/work/work/bbb/yocto-labs/meta-ti \
  /media/hcyang/work/work/bbb/yocto-labs/meta-mylayer \
  "
```
---

## 이미지 빌드

이제 준비가 끝났다 다음과 같이 빌드를 해 보면 끝에 새로 생성한 meta-mylayer가 master branch의 HEAD를 참조하며 빌드에 추가되어 있는 것을 확인할 수 있다. 

```bash
$ build MACHINE=beaglebone bitbake core-image-minimal

Loading cache: 100% |##########################################################################################################################################################################################################| Time: 0:00:00
Loaded 1506 entries from dependency cache.
NOTE: Resolving any missing task queue dependencies

Build Configuration:
BB_VERSION           = "1.37.0"
BUILD_SYS            = "x86_64-linux"
NATIVELSBSTRING      = "universal"
TARGET_SYS           = "arm-poky-linux-gnueabi"
MACHINE              = "beaglebone"
DISTRO               = "poky"
DISTRO_VERSION       = "2.5"
TUNE_FEATURES        = "arm armv7a vfp thumb neon callconvention-hard"
TARGET_FPU           = "hard"
meta                 
meta-poky            = "heads/sumo-19.0.0:65c77127cffed8b1750c52633119631dcfb99d50"
meta-ti              = "sumo:13572a44ba489f18bb5eca59495e695cb55ab5c4"
meta-mylayer         = "master:595fb0a774ae9a09ea01d5df0df5f8f4cb69dfb3"

Initialising tasks: 100% |#####################################################################################################################################################################################################| Time: 0:00:00
NOTE: Executing SetScene Tasks
NOTE: Executing RunQueue Tasks
NOTE: Tasks Summary: Attempted 2670 tasks of which 2670 didn't need to be rerun and all succeeded.
```

## 정리

이번 글에서는 임의의 Layer를 생성해 빌드에 추가하는 방법에 대해 정리해 보았다.


사실 생성된 이미지 자체는 이전과 다를게 없다. 다만 Yocto는 이미 만들어 져 있는 Recipe나 Layer의 코드를 변경하는 것 보다는 그것들에 새로운 것을 추가(append)하거나 빼서(exclude) 그 동작을 변경하는 것을 권장한다. 

이러한 의미에서 이번 예제는 Layer를 추가하고 여기에 임의의 Recipe를 넣어보는 것은 다른 사람들의 작업물 위에 나만의 작업물을 얹어 이미지를 만들어보는 전체적인 작업의 예가 될 수 있다.

앞선 두 글을 포함해 여기까지 기본적인 Yocto 구성 방법에 대해 알아보았다. 이제부터는 여러가지 예제를 다뤄보면서 Yocto에 익숙해 져 보자.