# BSP Layer 수정하기 #1 - Kernel Configuration 수정하기

몇 개의 문서를 통해서 Yocto에서 BSP Layer를 어떻게 수정하는지 정리 해보고자 한다.  그 첫 번째 순서로, 이번 문서에서는 Linux kernel의 config 파일을 수정해서 적용하는 방법을 알아보자.

이번 문서에서 사용되는 예제는  [지난 문서](2_Add_a_New_Layer_20190830.html)에 이어 작업하였다.

## Yocto TI BSP Layer의 Kernel Configuration
Yocto로 생성되는 이미지는 크게 Poky, BSP Layer, Application Layer 등으로 나눌 수 있다. 이 중 BSP Layer는 보통 타겟 머신의 CPU 제조사가 레퍼런스 보드에 맞게 배포한다. Beaglebone Black 용 BSP Layer도 TI 에서 배포한 BSP Layer를 사용한다. 

그러나 타겟 보드가 수정되거나, 원하는 기능들을 켜거나 끄고 싶을 때에는 BSP Layer의 내용을 수정해야 한다. 한편, Yocto에서는 이미 존재하는 Layer를 직접 수정하는 것 보다는 .bbappend 파일 등을 통해 수정 할 내용들을 Override 하도록 권장하지만, BSP Layer는 보드/CPU 제조사에 따라 그 구현방식(소스코드 Fetch / Patching / Configuration 등)이 달라지기 때문에 .bbappend를 작성하기 전에 수정하고자 하는 부분이 BSP Layer에서 어떻게 구현되어 있는지를 먼저 확인해 볼 필요가 있다.

예를들어, Yocto에서 Linux Kernel Configuration을 위한 Task인 do_configure() Task는 Beaglebone Black의 meta-ti Layer에서는 [meta-ti/recipes-kernel/linux/setup-defconfig.inc](http://git.yoctoproject.org/cgit/cgit.cgi/meta-ti/tree/recipes-kernel/linux/setup-defconfig.inc)에 다음과 같이 구현되어 있다.

```bash

do_configure() {
    # Always copy the defconfig file to .config to keep consistency
    # between the case where there is a real config and the in kernel
    # tree config
    cp ${WORKDIR}/defconfig ${B}/.config

    echo ${KERNEL_LOCALVERSION} > ${B}/.scmversion
    echo ${KERNEL_LOCALVERSION} > ${S}/.scmversion

    # Zero, when using "tisdk" configs, pass control to defconfig_builder
    config=`cat ${B}/.config | grep use-tisdk-config | cut -d= -f2`
    if [ -n "$config" ]
    then
        ${S}/ti_config_fragments/defconfig_builder.sh -w ${S} -t $config
        oe_runmake -C ${S} O=${B} "$config"_defconfig
    else
        # First, check if pointing to a combined config with config fragments
        config=`cat ${B}/.config | grep use-combined-config | cut -d= -f2`
        if [ -n "$config" ]
        then
            cp ${S}/$config ${B}/.config
        fi

        # Second, extract any config fragments listed in the defconfig
        config=`cat ${B}/.config | grep config-fragment | cut -d= -f2`
        if [ -n "$config" ]
        then
            configfrags=""
            for f in $config
            do
                # Check if the config fragment is available
                if [ ! -e "${S}/$f" ]
                then
                    echo "Could not find kernel config fragment $f"
                    exit 1
                else
                    # Sanitize config fragment files to be relative to sources
                    configfrags="$configfrags ${S}/$f"
                fi
            done
        fi

        # Third, check if pointing to a known in kernel defconfig
        config=`cat ${B}/.config | grep use-kernel-config | cut -d= -f2`
        if [ -n "$config" ]
        then
            oe_runmake -C ${S} O=${B} $config
        else
            yes '' | oe_runmake -C ${S} O=${B} oldconfig
        fi
    fi

    # Fourth, handle config fragments specified in the recipe
    # The assumption is that the config fragment will be specified with the absolute path.
    # E.g. ${WORKDIR}/config1.cfg or ${S}/config2.cfg
    if [ -n "${KERNEL_CONFIG_FRAGMENTS}" ]
    then
        for f in ${KERNEL_CONFIG_FRAGMENTS}
        do
            # Check if the config fragment is available
            if [ ! -e "$f" ]
            then
                echo "Could not find kernel config fragment $f"
                exit 1
            fi
        done
    fi

    # Now that all the fragments are located merge them
    if [ -n "${KERNEL_CONFIG_FRAGMENTS}" -o -n "$configfrags" ]
    then
        ( cd ${WORKDIR} && ${S}/scripts/kconfig/merge_config.sh -m -r -O ${B} ${B}/.config $configfrags ${KERNEL_CONFIG_FRAGMENTS} 1>&2 )
        yes '' | oe_runmake -C ${S} O=${B} oldconfig
    fi
}
```

특히 다음과 같이 가장 마지막에는 *KERNEL_CONFIG_FRGMENT* 환경변수에서 Kernel Configuration Fragment 파일들을 가져와 Merge 하는 작업을 거쳐 최종적인 .config 파일을 생성해 낸다.

```bash

    # Now that all the fragments are located merge them
    if [ -n "${KERNEL_CONFIG_FRAGMENTS}" -o -n "$configfrags" ]
    then
        ( cd ${WORKDIR} && ${S}/scripts/kconfig/merge_config.sh -m -r -O ${B} ${B}/.config $configfrags ${KERNEL_CONFIG_FRAGMENTS} 1>&2 )
        yes '' | oe_runmake -C ${S} O=${B} oldconfig
    fi

```
 [*Kernel Config Fragment*](https://www.yoctoproject.org/docs/latest/kernel-dev/kernel-dev.html#creating-config-fragments)  파일은 Yocto에서 Kernel Configuration에 적용할 수 있는 패치와 비슷한 형태의 파일이다.  이를 통해 각 모듈 별 개발자들은 자신들이 원하는 옵션들만 모아서 Kernel Config 파일들을 만들어 낼 수 있으며, 위 do_configure Task는 이를 모아서 하나의 .config 파일로 생성해 낸다.

 즉, 우리가 BSP Layer를 수정해야 할 일이 생기면 제조사가 배포한 BSP를 수정 할 필요 없이 다음과 같은 순서로 Linux Kernel (Configuration)의 수정이 가능하다.

 1. 나만의 Layer를 추가한다. (예 : meta-mylayer)
 2. Linux Kernel Recipe를 변경하기 위한 적절한 디렉토리 구조를 생성한다. (예 : meta-mylayer/recipe-kernel/linux)
 3. 수정할 Linux Kernel의 Recipe(.bb) 에 대한 .bbappend 파일을 적절한 생성한다.(예 : linux-ti-staging_4.14.bbappend)
 4. 필요한 파일들(소스코드 / 패치 / Kernel Config Fragment 등)을 적절히 배치한다. (예 : disable_cpu_trig.cfg)

이번 문서에는 [지난 문서](2_Add_a_New_Layer_20190830.html)의 예제에서 생성한 meta-mylayer Layer에 recipe-kernel이라는 디렉토리를 생성하여 작업하였다. 전체적인 파일 구조는 다음과 같으며, 하나 하나 자세히 알아보자.

```bash
$ yocto-labs tree meta-mylayer                            
meta-mylayer
├── COPYING.MIT
├── README
├── conf
│   └── layer.conf
├── recipes-apps
│   └── ninvaders
│       ├── ninvaders.inc
│       └── ninvaders_0.1.1.bb
└── recipes-kernel
    └── linux
        ├── files
        │   └── disable_cpu_trig.cfg
        ├── linux-ti-staging_4.14.bbappend

6 directories, 7 files
```

## 디렉토리 생성

우선 파일들을 생성하기 위한 디렉토리 구조를 잡아보자.

```bash
$ cd $HOME/yocto-labs/meta-mylayer
$ mkdir -p recipes-kernel/linux/files
```

## Kernel Config Fragment 생성
다음으로, files 디렉토리에 Kernel Config Fragment 파일을 생성해 보자.
이번 예제에서는 BBB의 LED 를 지속적으로 깜빡이게 하는 CPU LED Trigger 드라이버를 제거하도록 설정할 것이다.

``` bash
$ cd recipes-kernel/linux/files
$ vi disable_cpu_trig.cfg 
```

disable_cpu_trig.cfg 파일의 내용은 다음과 같다.
```bash
$ cat disable_cpu_trig.cfg 
# CONFIG_LEDS_TRIGGER_CPU is not set 
```


## bbappend 파일 추가

다음으로, 생성한 *disable_cpu_trig.cfg*  파일이 빌드 시에 포함되도록 Recipe를 수정할 것이다. 단, 직접 meta-ti BSP Layer의 Linux Kernel Recipe를 변경하는 것이 아니라 .bbappend 파일을 이용해서 우리에게 필요한 부분만 추가가 되도록 해 보자.

우선, bbappend 파일을 생성하기 위해서는 우리가 수정하고자 하는 Linux Kernel Recipe의 파일 명을 알아내어야 한다. 이를 위해 우리가 빌드 시 설정하는 MACHINE 환경 변수의 값인 beaglebone 에 대한 설정을 확인해 보자.

```bash
$ cd $HOME/yocto-labs/meta-mylayer
$ cat meta-ti/conf/machine/beaglebone.conf
#@TYPE: Machine
#@NAME: BeagleBone machine
#@DESCRIPTION: Machine configuration for the http://beagleboard.org/bone board 

require conf/machine/include/ti33x.inc
require conf/machine/include/beaglebone.inc

#이하 생략
```

이 파일은 *ti33x.inc* 파일과 *beaglebone.inc* 파일을 참조하고 있다. 먼저 *ti33x.inc*파일을 열어보자.

```bash
➜  yocto-labs cat meta-ti/conf/machine/include/ti33x.inc 
# 생략

# Default providers, may need to override for specific machines
PREFERRED_PROVIDER_virtual/kernel = "linux-ti-staging"
# 이하 생략
```
위와 같이 PREFERRED_PROVIDER_virtual/kernel 환경번수를 통해 *linux-ti-staging* 이라는 패키지가 Linux Kernel 빌드에 사용되도록 지정되어 있는 것을 확인 할 수 있다. 이제 *linux-ti-staging* 패키지의 Recipe를 찾아보자.


```bash
$ find meta-ti -name "linux-ti-staging*.bb*"
meta-ti/recipes-kernel/linux/linux-ti-staging_4.14.bb
meta-ti/recipes-kernel/linux/linux-ti-staging-systest_4.14.bb
meta-ti/recipes-kernel/linux/linux-ti-staging-rt_4.14.bb
```

위와 같이 linux-ti-staging_4.14.bb 파일이 우리가 확장하고자 하는 Linux Kernel의 Recipe임을 알 수 있다. 이제 meta-mylayer에 이에 대한 bbappend 파일을 생성해 보자.

```bash
$ vi meta-mylayer/recipes-kernel/linux/linux-ti-staging_4.14.bbappend
```

linux-ti-staging_4.14.bbappend 파일의 내용은 다음과 같다.

```bash
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += "file://disable_cpu_trig.cfg"
KERNEL_CONFIG_FRAGMENTS += "${WORKDIR}/disable_cpu_trig.cfg"
```

* Line #1 : disable_cpu_trig.cfg 파일이 저장되어 있는 files 디렉토리의 경로는 FILESEXTRAPATHS 변수에 추가한다.
* Line #2 : 참조 할 소스코드들이 나열되어 있는 SRC_URI 환경변수에 disable_cpu_trig.cfg 파일을 추가한다.
* Line #3 : KERNEL_CONFIG_FRAGMENTS  환경변수에 disable_cpu_trig.cfg 파일을 추가하여 빌드 시에 disable_cpu_trig.cfg 파일이 반영될 수 있도록 한다.

## 설정 확인

이제 빌드 할 모든 준비가 끝났다. 그러나 최종 패키지를 만들기 전에 menuconfig 를 통해 설정한 내용이 제대로 적용 되었는지 확인해 보자.

```bash
 MACHINE=beaglebone bitbake virtual/kernel -c cleansstate && \
 MACHINE=beaglebone bitbake virtual/kernel -c menuconfig
```
위 명령을 입력하고 나면 cleansstate Task가 기존 작업 내용들을 정리한 후 새 창으로 menuconfig 화면이 나타날것이다.

여기서 Device Drivers/LED Support/LED Trigger support/**LED CPU Trigger ** 항목이 Disabled 되어 있어야 한다.

## 빌드 및 확인

정상적으로 원하는 항목들이 적용된 것 까지 확인 되었으면 빌드 한 후 테스트 해 보자.

```bash
$ MACHINE=beaglebone bitbake core-image-minimal
```

빌드 후 만들어진 이미지를 보드에 올려 테스트 해 보면 CPU Trigger 드라이버를 제거했기 때문에 이와 관련된 LED 2와 3이 반짝이지 않는 것을 확인 할 수 있다.

## 정리 

이번 글에서는 Yocto에서 BSP Layer를 어떻게 수정하는지 알아보았다. Yocto에서는 기존에 존재하는 Layer를 바로 수정하는것을 권장하지 않기 때문에 새로 추가한 나만의 Layer에 .bbappend 파일을 추가함으로써 간접적으로 수정이 이루어지도록 해야 한다.

그 예제로 Linux Kernel Configuration을 수정하는 예제를 만들어 보았다. 이를 위해 CPU LED Trigger 드라이버를 제거하는 Kernel Configuration Fragment를 만들었고, 이를 적용하기 위해 Linux Kernel의 Recipe를 확장하는 bbappend 파일을 추가하여 만든 파일이 빌드에 적용될 수 있도록 하였다.

다음 문서에서는 이번 글을 확장하여 Linux Kernel의 패치를 만들어 적용해 보는 방법을 알아볼 계획이다.