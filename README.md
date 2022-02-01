# Introduce

개발 필요 기본 도구들

# 기본 사용법

```shell
brew tap ssfa/brew
brew install setup-mac

setup-mac setup_terminal   
setup-mac install_gui_apps  
```

# Development

## Documentaiton
 * [Ruby Programming Language](https://www.ruby-lang.org/en/)
   * [Thor is a toolkit for building powerful command-line interfaces.](https://github.com/erikhuda/thor)
 * [Homebrew Documentation](https://docs.brew.sh/)
   * [Taps (Third-Party Repositories)](https://docs.brew.sh/Taps)

## 특이사항
 * brew 의 특성상, 원격 저장소의 프로그램을 설치할수 있지만, 분리하면 복잡하여, [lib](./lib) 의 라이브러리들을 이용해서 해결한다.

## using pry
```shell
brew config | rg ruby
# cd 루비 패스로 이동
./gem install pry
# Formula 에서 require 'pry';binding.pry 이용 디버깅

brew irb --pry
```

## Issues

 * zsh 에서 커멘드 확인 후 가장 빠르게 설치하는 방법
 * [Speed Test: Check the Existence of a Command in Bash and Zsh - Top Bug Net](https://www.topbug.net/blog/2016/10/11/speed-test-check-the-existence-of-a-command-in-bash-and-zsh/)

```shell
for i in direnv goenv nodenv rbenv; do; (( $+commands[$i] )) || brew install $i; done
```
