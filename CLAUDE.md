# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 개요

Ruby 기반 CLI 도구들을 위한 Homebrew tap (`ssfa/brew`) Formula 저장소.

## 개발

```shell
# 로컬 개발: 현재 디렉토리를 tap 소스로 사용
brew tap ssfa/brew `pwd`

# 변경 후 Formula 재설치
brew reinstall <formula-name>

# 설치 문제 디버깅
brew install --verbose --debug <formula-name>
```

## 아키텍처

`Formula/`의 각 Formula는 `lib/ssfa/`의 세 가지 헬퍼 모듈 중 하나를 include한다:

- **`ThorScriptInstallHelper`** — zsh/bash 자동 완성을 포함한 Thor CLI 도구 (`setup-mac`, `works-alias`)
- **`RubyScriptInstallHelper`** — `scripts/`의 일반 Ruby 스크립트 (`rb`)
- **`BrewRubyHelper`** — .gemspec에서 빌드하는 gem 기반 도구 (`features`)

모든 헬퍼는 `Ssfa::Concern` (ActiveSupport::Concern 포크)을 사용하여 git remote에서 `homepage`, `url`, `depends_on`을 자동 설정한다. `brew --prefix`로 `ruby@3.4` 경로를 찾아 `GEM_HOME`과 `PATH`를 설정한다.

설치 흐름: Formula가 헬퍼를 include → 헬퍼가 `scripts/`의 스크립트를 Homebrew bin으로 복사 → gem 환경 및 셸 자동 완성 설정.

## Git 커밋 규칙

커밋 메시지는 [gitmoji](https://gitmoji.dev/) 스타일을 사용한다. 메시지 앞에 적절한 이모지를 붙인다. 이모지는 unicode 로 붙인다. 

예시:
- ✨ 새 기능 추가
- 🐛 버그 수정
- 🔧 설정 파일 변경
- 📝 문서 수정
- ♻️ 리팩토링
- 🚑 긴급 수정
- ✏️ 오타 수정

## 새 Formula 추가

1. `scripts/<command>.rb`에 스크립트 배치
2. `Formula/<command>.rb` 생성 후 적절한 헬퍼 include
3. 추가 gem이 필요하면 `install` 메서드 오버라이드
