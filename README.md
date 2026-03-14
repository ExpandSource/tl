# tl — Tutorial for Linux

리눅스 입문자를 위한 터미널 튜토리얼 도구.
터미널을 처음 켠 사람이 터미널을 즐기는 사람이 되는 흐름으로 구성.

```
$ tl
```

## 설치

### 바이너리 직접 빌드

```bash
git clone https://github.com/expandsource/tl
cd tl
make
bash install.sh
```

### .deb 패키지 (Debian / Ubuntu)

```bash
make deb
sudo dpkg -i dist/tl_0.0.2.deb
```

## 사용법

```
tl              인덱스 (카테고리 목록)
tl <n>          n단계 튜토리얼 목록
tl <n> <n>      n단계의 n번 모듈
tl <module>     모듈 직접 조회
tl z            마지막으로 읽은 모듈
tl n / tl next  다음 모듈
tl p / tl prev  이전 모듈
tl list         전체 모듈 목록
```

**예시**

```bash
tl          # 전체 단계 목록
tl 1        # 1단계 목록 (First Steps)
tl 1 3      # 1단계 3번 모듈
tl shell    # 모듈 직접 조회
tl n        # 다음으로
```

## 커리큘럼

| 단계 | 주제 | 모듈 수 |
|------|------|---------|
| 1 | First Steps | 5 |
| 2 | Files & Dirs | 10 |
| 3 | Text Editing | 7 |
| 4 | Permissions | 5 |
| 5 | Search & Pipe | 7 |
| 6 | Processes | 6 |
| 7 | Packages | 4 |
| 8 | Network | 7 |
| 9 | Your Environment | 11 |
| 10 | Scripting | 6 |
| 11 | System Admin | 6 |

## 구조

```
modules/
├── tl.conf          # 카테고리·모듈 순서 정의
├── 1/               # 단계별 폴더
│   ├── shell.txt
│   └── ...
└── ...
src/
└── tl.c
```

모듈 포맷 규칙 → [RULES.md](RULES.md)

## 제거

```bash
sudo make uninstall
# 또는
bash install.sh uninstall
```

설치 시 남기는 파일:

| 경로 | 내용 |
|------|------|
| `/usr/local/bin/tl` | 바이너리 |
| `/usr/share/tl/modules/` | 튜토리얼 모듈 |
| `/usr/share/bash-completion/completions/tl` | bash tab completion |
| `/usr/share/zsh/site-functions/_tl` | zsh tab completion |
| `~/.tl_state` | 진행 상태 |

## 빌드

```bash
make          # 빌드
make install  # /usr/local/bin/tl + /usr/share/tl/modules
make dist     # tarball (dist/tl-0.0.2.tar.gz)
make deb      # .deb 패키지 (Linux)
make clean    # 빌드 산출물 제거
```

의존성 없음. gcc만 있으면 됩니다.
