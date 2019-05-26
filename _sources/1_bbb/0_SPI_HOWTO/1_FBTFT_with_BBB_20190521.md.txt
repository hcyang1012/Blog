# FBTFT with Beaglebone Black

## Introduction
이 문서에서는 Beaglebone Black에 SPI 기반으로 동작하는 TFT LCD를 연동하는 예제를 기술하고자 한다.

이를 위해 먼저 시스템이 구성하기 위해서는 어떠한 것들이 필요한지 알아보고, 각 요소들을 설정하여 LCD 사용하기 위한 환경을 구성해 볼 것이다.

또한 LCD 를 사용할 수 있는 환경이 구성된 후 이를 이용해 몇 가지 예제를 동작시켜 볼 것이다.

## 준비물
- Beaglebone Black
- [ST7735R 기반 TFT LCD](https://makeradvisor.com/tools/1-8-tft-lcd-display/)

## 설정이 필요한 것들

아래 그림은 본 예제가 동작하기 위해 필요한 HW / SW 기능들을 간단히 그려본 그림이다. 이 그림들을 하나 하나 뜯어보면 무엇을 설정해 주어야 하는지 알 수 있다.

![](https://docs.google.com/drawings/d/e/2PACX-1vSvMJXwJW91CauYh9FlOITSDYTx4txl8zM7xj_AoebzpFBgKsREDzvu1wRZy_DnW2e3E4O6C6trHOa6/pub?w=1383&h=1334
)

### TFT LCD와 BBB의 연결 
그림 맨 아래에는 BBB와 TFT LCD가 SPI와 GPIO 두 가지 채널로 연결되어 있음을 알 수 있다. 핀맵에 맞추어 도선을 연결해 주면 된다. 구체적인 핀맵은 잠시 후에 알아보자. 

### SPI / GPIO 설정
BBB에 장착되어 있는 SOC인 AM335x는 SPI와 GPIO Peripheral 을 모두 제공한다. 그러나 이 장치들을 제대로 사용해 주기 위해서는 몇 가지 설정을 해 주어야 한다. 이 예제에서 해 주어야 하는 것들은 다음과 같은 것들이 있다.

1. PINMUX : 
대부분의 SOC의 외부로 나와 있는 핀은 특정 장치와 1:1로 연결되어 있는 것이 아니라 여러 가지 내부 장치들과 연결되어 있다. 따라서 내가 사용하고자 하는 핀의 목적에 따라 그 핀을 어떤 장치와 연결시킬 지 설정해 주어야 한다. ARM 리눅스 기반 시스템에서는 Device Tree의 PINMUX Section을 통해 이를 설정 할 수 있다.


2. Device Driver Enable : 
리눅스에서는 부팅시간이나 커널이 사용하는 메모리 사용량을 최소화하기 위해 시스템이 동작하기 위한 최소한의 기능들만 부팅 시에 동작시킨다. 예를 들어, SPI 디바이스 드라이버나 GPIO 디바이스 드라이버가 만들고자 하는 시스템에 필요 없다면 굳이 처음부터 동작시킬 필요는 없을 것이다. 하지만 이번 예제에서는 SPI 및 GPIO 가 필요하기 때문에 이 두 가지 장치에 대한 디바이스 드라이버를 활성화 시킬 필요가 있다. 이 역시 Device Tree의 *status* 속성을 통해 설정 가능하다.(단, BBB가 사용하는 Device Tree에서는 GPIO는 기본값으로 활성화 상태가 설정되어 있기 있기 때문에 SPI 디바이스 드라이버만 활성화 시켜 주면 된다.)


### Subsystem 사용
리눅스에서는 각 장치에 대한 Device Driver에 직접 접근해서 장치를 사용하는 것 보다는 Device Driver와 연결되어 있는 Subsystem이 제공하는 API를 통해서 접근하는 것을 권장하고 있다. 이미 AM335x용 Device Driver는 각 Subsystem들과 연동이 잘 되도록 구현되어 있으니 우리는 특별히 신경을 쓸 필요는 없다.


### LCD Device Driver
LCD Controller도 결국 하나의 장치이기 때문에 이를 위한 Device Driver가 필요하다. 당연하겠지만 이 Device Driver가 SPI와 GPIO Subsystem 을 이용하여 LCD를 제어하는 구조이기 때문에 개발자는 SPI / GPIO 설정을 LCD Device Driver에게 알려 주기만 하면 될 뿐, 이를 사용하는 User Application은 SPI와 GPIO에 직접 접근할 필요가 없다. 여기서는 FBTFT라는 Device Driver를 이용할 것이다. 이 Device Driver는 SPI 기반으로 동작하는 여러 종류의 LCD Controller를 지원하며, 이 때문에 Controller의 이름과 SPI Subsystem 및 GPIO Subsystem에 접근하기 위한 SPI 채널 및 GPIO Name만 알려주면 쉽게 TFT LCD의 사용이 가능하게 해 준다.


### User Application
Kernel Level에서 LCD 용 Device Driver가 동작하게 하였더라도 Device Driver가 제공하는 인터페이스를 알아야 User Application이 LCD를 사용할 수 있을 것이다.LCD 접근하기 위한 가장 대표적인 LCD Interface가 */dev/fbx*로 표현되는 Frame Buffer interface를 이용하는 것으로, FBTFT 역시 이를 지원한다. 이번 예제에서는 이룰 통해 간단히 TFT LCD에 Random Dots를 출력해 볼 것이다.


## H/W 연결
아래 표와 같이 연결해 주자

|  LCD  | BBB_NAME | BBB_PIN# |
|:-----:|:--------:|:--------:|
|  LED  |   3.3V   |   P9_03  |
|  SCK  |   SCLK   |   P9_22  |
|  SDA  |   MOSI   |   P9_18  |
|   A0  | GPIO1_28 |   P9_12  |
| RESET | GPIO1_16 |   P9_15  |
|   CS  |    CS    |   P9_17  |
|  GND  |    GND   |   P9_01  |
|  VCC  |    5V    |   P9_05  |

## Device Tree 편집

요즘은 Device Tree 편집이 필요할 시 Device Tree Overlay를 많이 사용하는데, 개인적으로는 좋아하는 방식이 아니라 부팅 시 읽어들이는 Device Tree에 직접 편집해 넣었다. (arch/arm/boot/dts/am335x-boneblack.dts)

Device Tree를 빌드하고 적용하는 예제는 [이 링크](https://www.digikey.com/eewiki/display/linuxonarm/BeagleBone+Black) 를 참조하자.

### PIN MUX for SPI0

이번 예제에서는 SPI 0를 사용했다.

> 참고 : Beaglebone Black는 HDMI 사용을 위해 SPI1를 미리 예약해 두고 있다. SPI1 을 사용하려면 HDMI 기능도 함께 제거 후 사용해야 한다. 여기서는 그냥 SPI0를 사용하였다.

```
spi0_pins:spi0_pins{
	pinctrl-single,pins = <
		AM33XX_IOPAD(0x95c, PIN_OUTPUT_PULLUP | MUX_MODE0)			/* P9_17, 87, SPI0_CS0 */
		AM33XX_IOPAD(0x950, PIN_INPUT_PULLUP | MUX_MODE0)			/* P9_22, 84, SPI0_CLK */
		AM33XX_IOPAD(0x954, PIN_INPUT_PULLUP | MUX_MODE0)       	/* P9_21, 85, SPI0_MISO */
		AM33XX_IOPAD(0x958, PIN_OUTPUT_PULLUP | MUX_MODE0)	        /* P9_18, 86, SPI0_MOSI */
	>;
};
```

Beaglebone Black의 Pin 들 중 SPI를 위한 핀 4 개를 SPI 용으로 설정해 주어야 한다. BBB의 AP인 AM335x 의 PINMUX 설정은 AM335x Reference Manual 을 보아야 하지만, 이에 대한 자세한 설명은 이 글의 범위를 벗어난다. 

다만 BBB에서 사용하는 PIN들에 대한 PINMUX는 [이 문서](https://itbrainpower.net/a-gsm/images/BeagleboneBlackP9HeaderTable.pdf) 에 잘 표현되어 있다. 위 Device Tree 코드와 문서를 비교하면 쉽게 어떠한 설정을 하였는지 알 수 있을 것이다.
 
### SPI Enable
SPI는 간단하다. SPI를 그냥 Enable 시켜주면 된다.

```
&spi0 {
	status="okay";
	pinctrl-names = "default";
	pinctrl-0 = <&spi0_pins>;
};
```
완전한 소스코드는 [이 링크](https://gist.github.com/hcyang1012/2e13e6b16bc475f0b449fa141225508a)를 참조하자.

## FBTFT 설정

이 문서에서 사용하는 LCD는 ST7735R 이라는 LCD 컨트롤러에 의해 제어되며, ST7735R 컨트롤러는 SPI로 제어가 가능하다. 따라서 SPI로 ST7735R을 제어하는 Device Driver가 필요한데, [FBTFT](https://github.com/notro/fbtft) 라는 프로젝트에서 이 드라이버를 제공한다. 

### 드라이버 로드
BBB에서 사용하는 리눅스 커널은 이 드라이버가 기본으로 포함되어 빌드되기 때문에 따로 커널이나 모듈을 빌드해야 할 필요는 없다. 다음과 같이 모듈을 로드해 보자

```bash
$) sudo modprobe fbtft_device busnum=1 name=adafruit18 debug=7 verbose=3 gpios=dc:60,reset:48
```

명령을 보면 fbtft_device라는 모듈을 로드하면서 몇 가지 파라메터를 주는 것을 알 수 있다. 주요 항목들에 대한 설명은 다음과 같다. 

1. busnum = 1 : SPI 0 버스를 사용할 것이다. (AM335x는 SPI0 / SPI1 두 개의 SPI 장치를 가지고 있으나, Linux SPI Subsystem에서는 이를 각각 SPI1 / SPI2에 매핑하여 사용한다.)
2. name=adafruit18 : adafruit18 LCD 는 ST7735R을 사용하는 LCD 보드이다. 이 때문에 우리는 이 장치에 대한 드라이버를 사용할 것이다.
3. gpios=dc : 60, reset:48 : GPIO 60 은 GPIO1_28(32*1 + 28 = 60)을, GPIO 48 은 GPIO1_16(32 * 1 + 16 = 48) 을 의미한다. H/W 설정 시 GPIO1_28 및 GPIO1_16을 사용하기로 설정하였기 때문에 이와 같이 FBTFT 드라이버에 어느 GPIO를 어떤 목적으로 사용할 지 알려주었다.

### 드라이버 테스트

정상적으로 드라이버가 동작하고 있다면 */dev/fb1*이라는 파일이 생성되어야 한다.
> 참고 : /dev/fb0는 BBB의 HDMI Interface가 사용하고 있다.

여기에 다음과 같은 명령을 실행해 보면 LCD에 임의의 위치에 임의의 색깔의 점이 표시되는 것을 확인할 수 있을 것이다.
``` bash
cat /dev/urandom /dev/fb1
```

### 추가 예제
[FBTFT 위키](https://github.com/notro/fbtft/wiki/Framebuffer-use) 에 가 보면 몇 가지 좀 더 해볼 수 있는 예제가 있다. 예를 들어, 다음 예제는 리눅스 콘솔을 LCD로 포워딩(Forwarding) 하는 예제이다.

``` bash
$) sudo apt-get install fbset
# Map console 1 to framebuffer 1, login screen will show up on the display
$) con2fbmap 1 1
```

### 부팅 시 자동으로 로드되게 하기
아무래도 modprobe 명령을 매 번 입력하기에는 비효율적이다. */etc/modprobe.d* 디렉토리에 *fbtft.conf*파일을 만들어 부팅 시에 자동으로 드라이버를 로드하고 위 옵션들이 적용되게 할 수 있다.

``` bash 
#/etc/modprobe.d/fbtft.conf
options fbtft_device busnum=1 name=adafruit18 debug=7 verbose=3 gpios=dc:60,reset:4 rotate=90
```

### 정리 
이 문서에서는 Beaglebone Black 에서 작은 TFT LCD를 제어하는 방법에 대해 알아보았다. 사용된 LCD는 ST7735R LCD 컨트롤러를 통해 제어가 가능하고, ST7735R은 SPI와 GPIO를 통해 제어가 가능하다.

따라서 먼저 Device Tree 설정을 통해 SPI와 GPIO 설정을 해 주었고, 이를 기반으로 FBTFT 디바이스 드라이버를 로드해 보았다. 또한 FBTFT 드라이버는 ST7735R 뿐 아니라 여러 LCD 컨트롤러에 대한 드라이버를 지원하기 때문에 modprobe 로 모듈 로드 시 어떠한 컨트롤러를 사용할 지, 그리고 어떤 SPI 채널과 GPIO 핀들을 사용할 지 옵션으로 알려주었다.

또한 FBFTF를 로드하고 난 후 임의의 점을 표시하거나, 콘솔 화면을 띄워 보는 등 몇 가지 방법을 통해 LCD를 제어해 보았다. 마지막으로 modprobe.d 에 fbtft와 관련된 파일을 추가하여 부팅 시 드라이버가 자동으로 로드되도록 설정해 보았다.

재밌는 점은 다소 멀리 돌아왔지만 SPI를 사용하는 예제임에도 단순히 SPI 채널 설정정도만 했을 뿐 실제 장치를 사용하는 입장에서는 SPI 인터페이스를 전혀 사용하지 않았다는 점이다. 이러한 방법은 비교적 여러 단계의 Abstraction과 Subsystem들을 통해 가능하게 된 것으로, 아두이노와 같은 Firmware수준에서 SPI를 제어하거나 SPIDEV와 같이 SPI Command를 직접 전달하는 예제와 비교된다.