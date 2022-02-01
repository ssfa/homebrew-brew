## 도구 설치

```bash
brew tap ssfa/brew
brew install setup-mac
```

## 터미널 도구

```bash
setup-mac setup_terminal     # zinit 설치, .zshrc 기본 값 제공
```

- [homebrew-brew/setup-mac.rb](https://github.com/ssfa/homebrew-brew/blob/master/scripts/setup-mac.rb#L47)

### zsh 키 설명

- [homebrew-brew/.zshrc](https://github.com/ssfa/homebrew-brew/blob/master/scripts/.zshrc)

```bash
^e => 커서 가장 뒤로 or 자동 추천된 최근 명령어 완성
^r => 과거 명령어 fuzzy 검색
^u => 현재 줄 지우기
^t => 현재 폴더 기준으로 파일명 fuzzy 검색

^xe => 현재 입력을 vim 을 열어서 멀티라인 편집
```

### 설치된 터미널 도구 참고 명령어

```bash
git_aliases       # git 단축 명령어들
features_aliases  # f, fco 설명

z [cmd]    # 최근 이용한 디렉토리 fuzzy 검색해서 이동
tldr [cmd] # 명령어 사용 방법 출력

rg       # grep 대체 가장 빠른 text 검색기
fzf      # 입력 받은 stdin 를 fuzzy 검색후 출력
bat      # cat 대체 (alias 되어 있음)
jq       # json, yml query
```

## GUI Apps

```bash
setup-mac install_gui_apps   # 사무, 개발 앱들 일괄 설치 
```

- [homebrew-brew/setup-mac.rb](https://github.com/ssfa/homebrew-brew/blob/master/scripts/setup-mac.rb)