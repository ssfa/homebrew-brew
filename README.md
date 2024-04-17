# Introduce

```shell
brew tap ssfa/brew
brew install setup-mac

setup-mac setup_terminal   
setup-mac install_gui_apps  
```

# Development Tip

## 인증

### 방법1

```shell
gh auth login
brew tap ssfa/brew
```

### 방법2

[Using a personal access token on the command line](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

```shell
$ git clone https://github.com/USERNAME/REPO.git
Username: YOUR_USERNAME
Password: YOUR_PERSONAL_ACCESS_TOKEN
brew tap ssfa/brew
```

### Github 로그인 삭제

```shell
echo -e "protocol=https\nhost=github.com" | git credential-store erase
```

## 로컬 패스를 tap 으로 할수 있다.

```shell 
brew untap ssfa/brew
brew tap ssfa/brew `pwd`
```

## Documentaiton

* [Ruby Programming Language](https://www.ruby-lang.org/en/) 
* [Thor is a toolkit for building powerful command-line interfaces.](https://github.com/erikhuda/thor)
* [Homebrew Documentation](https://docs.brew.sh/)
    * [Taps (Third-Party Repositories)](https://docs.brew.sh/Taps)

## 특이사항


## Issues

* zsh 에서 커멘드 확인 후 가장 빠르게 설치하는 방법
* [Speed Test: Check the Existence of a Command in Bash and Zsh - Top Bug Net](https://www.topbug.net/blog/2016/10/11/speed-test-check-the-existence-of-a-command-in-bash-and-zsh/)

```shell
for i in direnv goenv nodenv rbenv; do; (( $+commands[$i] )) || brew install $i; done
```

# Development

```shell
brew tap --force homebrew/core
brew tap ssfa/brew `pwd`
```
