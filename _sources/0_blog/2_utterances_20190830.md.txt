# utterances로 댓글 시스템 구축하기

블로그에 댓글 시스템을 구축하고 싶은데 많이 쓰이는 [DISQUS](https://disqus.com/)는 사용이 뭔가 불편하고 원하지 않는 댓글도 많이 달린다는 이야기가 보여서 우연히 찾은 [utterances](https://utteranc.es/)  를 쓰기로 했다. 

utterances는 동작 방식이 독특하다.글에 달리는 댓글들이 Github의 이슈 게시판에 이슈로서 등록되며, 이 이슈들을 댓글 창 형태로 보여준다. 설치도 간단하다. 

## 설치 방법

### Github Repository 생성
utterances는  Github Repository의 이슈 게시판과 연동되기 때문에 연동할 Repository를 Github에 생성해 줄 필요가 있다. 나는 [blog-comment](https://github.com/hcyang1012/blog-comment) 라는 빈 저장소를 만들었다.

### utterances app  설치
다음으로 생성한 Github 저장소에 utterances app 을 설치해야 한다. [설치 사이트](https://github.com/apps/utterances)에서 Install 버튼을 눌러 저장소와 관련된 정보만 입력해주면 내 저장소가 utterance app 과 연동된다.

### 설치 스크립트 생성하기
uttrances의 댓글 창은 각 본문의 원하는 위치에 댓글 창을 생성하는 자바스크립트 코드만 추가해 주면 쉽게 설치가 가능하다. 추가해야 하는 자바스크립트 코드는 [utterance 사이트](https://utteranc.es/)에서 설문조사 하듯이 몇 가지 항목만 채워주면 생성이 가능하다.  나는 다음과 같이 채워넣었다.

- Repo : *hcyang1012/blog-comment*
- Blog post / issue mapping : *Issue title contains page pathname* 
- Issue label : *blank*
- Theme : *Github light*

원하는대로 채워 넣었으면 맨 아래에 생성되는 코드를 블로그 포스트의 원하는 위치에 붙여넣으면 된다. 아래는 내 블로그에서 사용하는 코드이다.

```html

<script src="https://utteranc.es/client.js"
        repo="hcyang1012/blog-comment"
        issue-term="pathname"
        theme="github-light"
        crossorigin="anonymous"
        async>
</script>

```

## 블로그에 코드 붙여넣기
앞서 생성한 코드를 블로그에 추가해 보자. 이 부분은 사용자마다 달라질 수 있다. 나의 경우에는 Markdown으로 블로그 본문을 작성하고, Sphinx로 html 문서를 생성하기 때문에 Sphinx의 template 기능을 이용하여 모든 본문의 끝에 댓글 코드가 추가되도록 하였다.

지금부터는 내 블로그 환경 기준으로 추가한 방법을 기술하겠다.

### templates_path 변수 확인

먼저, Sphinx에서 template 파일을 어디서 읽어오는지 확인이 필요하다.  conf.py 의 templates_path 변수가 이를 결정한다. 나의 경우는 아래 코드와 같이 *_templates* 디렉토리에 있는 파일에서 template 을 읽어오도록 되어 있다.

```python
# conf.py
# 중간 생략
templates_path = ['_templates']
```

### template 파일 추가

현재 내 블로그에는 *_templates* 디렉토리가 없기 때문에 *_templates* 디렉토리와 함께 *layout.html * 파일도 생성했다. layout.html 파일의 본문은 아래와 같다. 


```html
{% extends "!layout.html" %}
{% block extrahead %}



{% endblock %}

{% block footer %}

<script>
{{ super() }}
</script>
{% endblock %}

{% block comments %}
<script src="https://utteranc.es/client.js"
        repo="hcyang1012/blog-comment"
        issue-term="pathname"
        theme="github-light"
        crossorigin="anonymous"
        async>
</script>
{% endblock %}
```
위 내용을 보면 본문(*{{super()}}*) 아래에 utterances 사이트에서 생성한 코드를 추가하도록 해 둔 것을 볼 수 있다. 이렇게 한 후 블로그를 확인하면 본문 아래에 댓글창이 생성된 것을 볼 수 있다.

### 기타
나의 경우 처음에 위와 같이 코드를 추가 후 블로그에서 설치 결과를 확인 시 바로 생성이 되지 않았다. utterances는 여러가지 이슈로 [utterances-bot](https://github.com/utterances-bot) 과의 연동이 필요한데, 이 때문인 것 같다. 아마 일정 주기로 봇이 내 블로그와 동기화가 되도록 설정해 두었기 때문에 댓글 창을 사용하려면 어느정도 시간이 필요한 것 같았다. 나의 경우 약 10분정도 기다리고 나니 정상적으로 댓글 창이 생성되었다. 참고하자.

또한, 위 편집 내용들은 [이 커밋](https://github.com/hcyang1012/blog/commit/7efc3af2f806114556bc6a0bb0973374547875b1) 에 기술되어 있으니 필요하면 참고하면 좋을 것이다.