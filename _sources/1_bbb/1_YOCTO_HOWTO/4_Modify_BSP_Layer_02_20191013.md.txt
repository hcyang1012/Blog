# BSP Layer 수정하기 #2 - Kernel Module 추가하기

 [지난 문서](3_Modify_BSP_Layer_01_20190928.html)에 이어 이번 문서에서는 원하는 커널 모듈 (Kernel Module)을 추가하는 방법에 대해 기술하고자 한다. 커널 모듈을 추가하는 방법은 크게 1) 리눅스 커널에 직접 소스코드를 추가 하는 방법과 2) 외부에서 따로 빌드하는 방법(Out-of-tree)이 있다. 첫 번째 방법은 다음 문서에서 다루고, 이번 문서에서는 두 번째 방법을 다루겠다.

 ## Recipe 추가하기
 먼저, [지난 문서](3_Modify_BSP_Layer_01_20190928.html)에서 만든 recipes-kernel 디렉토리에 새로 추가 할 커널 모듈의 Recipe를 추가해 보자.

 ```bash
 $ cd meta-mylayer
 $ mkdir -p recipes-kernel/mymodule
 ```

 다음으로 다음과 같이 Recipe 파일들을 생성하자. 
 ```bash
$ tree mymodule 
mymodule
├── mymodule.inc
└── mymodule_0.1.1.bb
 ```

*mymodule.inc* 파일은 버전에 관계 없이 소스코드를 가져오고, 빌드하기 위한 방법에 대한 내용들이 기술 할 파일이고, *mymodule_0.1.1.bb* 파일은 Version-Specific 내용들을 기술 할 파일이다.

### mymodule.inc 파일 작성
mymodule_inc 파일의 나용은 다음과 같다.

``` bash
SUMMARY = "A sample out-of-tree kernel module"
SECTION = "base"

inherit module

SRC_URI = "git://github.com/hcyang1012/Beaglebone_Kernel_Examples.git;branch=yocto_project"
SRC_URI[md5sum] = "42a5d1604536ab735fab725d8a60c27b"
SRCREV="${AUTOREV}"
S = "${WORKDIR}/git/01_misc"


KERNEL_MODULE_AUTOLOAD = "01_misc"                                                                                        
```

주요 내용들은 다음과 같다.
1. inhert module : Kernel Module을 빌드하기 위한 Class인 *module* class를  상속받는다.
2. SRC_URI : 이번 예제에서는 [미리 작성해 놓은 커널 모듈](https://github.com/hcyang1012/Beaglebone_Kernel_Examples)을 다운로드 받아 빌드 할 것이다. 단, *yocto_project*라는 Branch를 사용할 것이기 때문에 SRC_URI의 끝에 branch parameter를 넣어 주었다.
3. SRCREV : Git을 통해서 소스 코드를 다운로드 받는 경우에는 tag나 commit ID 등을 SRCREV 환경변수를 통해서 명시 해 주어야 한다. 특별히 사용해야 할 버전이 없는 경우라면 *${AUTOREV}* 변수로 최신 버전(HEAD)을 사용하도록 할 수 있다.
4. 일반적으로 S 변수는  *${WORKDIR}* 과 같은 형태로 지정하지만, git을 통해 다운로드 받는 경우에는 *${WORKDIR}/git*과 같이 git directory를 지정해 주어야 하고, 이번 예제의 경우 01_misc 디렉토리에 있는 소스코드를 사용할 것이기 때문에 *{WORKDIR}/git/01_misc* 과 같이 Working Directory를 지정해 주었다. 
5. 마지막으로, 부팅 시 자동으로 모듈이 로드되게 하기 위해 KERNEL_MODULE_AUTOLOAD 환경 변수에 작성한 모듈의 이름을 지정해 주었다.

### mymodule_0.1.1.bb 파일 작성
 mymodule_0.1.1.bb 파일의 내용은 다음과 같다.

 ``` bash
 require mymodule.inc

LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://../LICENSE;md5=1ebbd3e34237af26da5dc08a4e440464"
 ```

 특별한 내용은 없지만, LICENSE 파일의 경로가 Working Directory보다 상위 위치에 있기 때문에 *../LICENSE 로 명시한 것에 주의 하자*.

## Makefile 작성

[이번 문서에서 사용하는 예제 모듈](https://github.com/hcyang1012/Beaglebone_Kernel_Examples)은 yocto_project라는 branch를 사용한다. 이렇게 Branch를 생성한 이유는 Makefile을 Yocto Project에 맞게 변경하기 위해서이다.  있는 그대로 템플릿으로 사용해도 좋고, [이 링크](https://github.com/hcyang1012/Beaglebone_Kernel_Examples/commit/6e64b720f2c5fabffe6c544ccf8b704f71b1324d)를 통해 변경된 점이 무엇인지 한번 확인해 보는 것도 좋을 것이다.

## Layer conf 파일에 Recipe 추가
이제 Recipe의 작성은 끝이 났다. 마지막으로 빌드에 만들어 둔 Recipe가 추가되도록 meta-mylayer/conf/layer.conf에 다음 줄을 추가하자

``` bash
IMAGE_INSTALL_append = " mymodule
```

작성 완료 된 파일 내용은 다음과 같다.
``` bash
# We have a conf and classes directory, add to BBPATH
BBPATH .= ":${LAYERDIR}"

# We have recipes-* directories, add to BBFILES
BBFILES += "${LAYERDIR}/recipes-*/*/*.bb \
            ${LAYERDIR}/recipes-*/*/*.bbappend"

BBFILE_COLLECTIONS += "meta-mylayer"
BBFILE_PATTERN_meta-mylayer = "^${LAYERDIR}/"
BBFILE_PRIORITY_meta-mylayer = "6"

IMAGE_INSTALL_append = " ninvaders"
IMAGE_INSTALL_append = " mymodule"

```

## 테스트
이제 필요한 내용들은 모두 추가하였다. 이미지를 빌드 후 타겟이 올린 후 insmod 명령을 통해 01_misc 모듈이 추가되었는지 확인해 보자.

``` bash
$ lsmod
    Tainted: G  
01_misc 16384 0 - Live 0xbf000000 (O)
```

위와 같이 01_misc 모듈이 부팅 시 자동으로 로드되어 있는 것을 확인할 수 있다.

## 정리
이번 문서에서는 Out-of-tree Kernel Module를 구성하는 방법에 대해 알아보았다. 이번 예제도 일반적인 Recipe를 만드는 것과 절차적으로는 크게 다를 것이 없으나, 1) *module* 이라는 bbclass를 상속받아 Recipe를 만들었다는 점과, 2) *KERNEL_MODULE_AUTOLOAD* 환경 변수를 통해 자동으로 모듈이 로드될 수 있도록 한 점이 이제까지의 예제들과는 다른 점이였다.

다음 문서에서는 직접 리눅스 커널에 모듈을 추가해 봄으로써 커널 소스 코드를 수정하는 방법에 대해 알아 볼 것이다.