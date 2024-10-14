#!/bin/bash

# 환경 변수 설정
export WORK="/root/birds"
export NVM_DIR="$HOME/.nvm"

# 색상 정의
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # 색상 초기화

echo -e "${GREEN}Birdsui 봇을 설치합니다.${NC}"
echo -e "${GREEN}스크립트작성자: https://t.me/kjkresearch${NC}"
echo -e "${GREEN}출처: https://github.com/hokireceh/birds${NC}"

echo -e "${CYAN}이 봇은 다음과 같은 기능을 갖고 있습니다.${NC}"
echo -e "${CYAN}웜캐칭 / 에그업그레이드/ 에그크래킹 / 각종 태스크${NC}"

echo -e "${GREEN}설치 옵션을 선택하세요:${NC}"
echo -e "${YELLOW}1. Bird 봇 새로 설치${NC}"
echo -e "${YELLOW}2. 기존정보 그대로 이용하기(재실행)${NC}"
read -p "선택: " choice

case $choice in
  1)
    echo -e "${GREEN}Bird 봇을 새로 설치합니다.${NC}"

    # 사전 필수 패키지 설치
    echo -e "${YELLOW}시스템 업데이트 및 필수 패키지 설치 중...${NC}"
    sudo apt update
    sudo apt install -y git

    echo -e "${YELLOW}작업 공간 준비 중...${NC}"
    if [ -d "$WORK" ]; then
        echo -e "${YELLOW}기존 작업 공간 삭제 중...${NC}"
        rm -rf "$WORK"
    fi

    # GitHub에서 코드 복사
    echo -e "${YELLOW}GitHub에서 코드 복사 중...${NC}"
    git clone https://github.com/hokireceh/birds.git
    cd "$WORK"

    # 필수 패키지 설치
    echo -e "${YELLOW}시스템 업데이트 및 필수 패키지 설치 중...${NC}"
    sudo apt update
    sudo apt install -y python3 python3-pip
    pip3 install -r requirements.txt

    echo -e "${GREEN}여러 개의 query_id를 입력할 경우 줄바꿈으로 구분하세요.${NC}"
    echo -e "${GREEN}입력을 마치려면 엔터를 두 번 누르세요.${NC}"
    echo -e "${YELLOW}query_id를 입력하세요:${NC}"
    
    # 쿼리 파일 생성 및 초기화
    {
        while IFS= read -r line; do
            [[ -z "$line" ]] && break
            echo "$line"
        done
    } > "$WORK/data.txt"

    # 사용자에게 프록시 사용 여부를 물어봅니다.
    read -p "프록시를 사용하시겠습니까? (y/n): " use_proxy
    
    if [[ "$use_proxy" == "y" || "$use_proxy" == "Y" ]]; then
        # 프록시 정보 입력 안내
        echo -e "${YELLOW}프록시 정보를 입력하세요. 입력형식: http://user:pass@ip:port${NC}"
        echo -e "${YELLOW}여러 개의 프록시는 줄바꿈으로 구분하세요.${NC}"
        echo -e "${YELLOW}입력을 마치려면 엔터를 두 번 누르세요.${NC}"

        # 프록시 정보를 임시로 저장할 배열 선언
        proxies=()

        # 프록시 정보 입력 받기
        while IFS= read -r line; do
            [[ -z "$line" ]] && break
            proxies+=("$line")
        done

        # Python을 사용하여 JSON 생성
        python3 -c "
import json
import sys

proxies = sys.argv[1:]
data = {
    'accounts': [{'acc_info': '', 'proxy_info': proxy} for proxy in proxies]
}
print(json.dumps(data, ensure_ascii=False))
" "${proxies[@]}" > "$WORK/data-proxy.json"

        echo -e "${GREEN}프록시 정보가 data-proxy.json 파일에 저장되었습니다.${NC}"
        
        # 봇 구동
        python3 bot-proxy.py
    else
        python3 bot.py
    fi
    ;;
    
  2)
    echo -e "${GREEN}Bird 봇을 재실행합니다.${NC}"
    
    # 사용자에게 프록시 사용 여부를 물어봅니다.
    read -p "프록시를 사용하시겠습니까? (y/n): " use_proxy
    cd "$WORK"
    git pull
    if [[ "$use_proxy" == "y" || "$use_proxy" == "Y" ]]; then
        python3 bot-proxy.py
    else
        python3 bot.py
    fi
    ;;

  *)
    echo -e "${RED}잘못된 선택입니다. 다시 시도하세요.${NC}"
    ;;
esac
