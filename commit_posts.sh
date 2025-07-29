#!/bin/bash

# 1. _posts 디렉토리 확인
POST_DIR="_posts"

if [ ! -d "$POST_DIR" ]; then
  echo "❌ _posts 디렉토리가 존재하지 않습니다."
  exit 1
fi

# 2. 커밋을 날짜순으로 정렬: 오래된 것부터 커밋
# 파일명이 YYYY-MM-DD-title.md 형식일 경우
FILES=$(ls "$POST_DIR" | grep -E "^[0-9]{4}-[0-9]{2}-[0-9]{2}-.+\.md$" | sort)

for FILE in $FILES; do
  DATE=$(echo "$FILE" | cut -d'-' -f1-3)  # YYYY-MM-DD 추출
  TITLE=$(echo "$FILE" | cut -d'-' -f4- | sed 's/.md$//')

  # 커밋할 파일 경로
  FILE_PATH="$POST_DIR/$FILE"

  # Git이 추적하지 않으면 add
  git add "$FILE_PATH"

  # 커밋 존재 여부 확인
  if git log -- "$FILE_PATH" &> /dev/null; then
    echo "⚠️  $FILE 은 이미 커밋되어 있음. 생략."
    continue
  fi

  # 커밋
  GIT_AUTHOR_DATE="$DATE 12:00:00" GIT_COMMITTER_DATE="$DATE 12:00:00" \
  git commit -m "Add post: $TITLE ($DATE)" --date="$DATE 12:00:00"

  echo "✅ 커밋 완료: $FILE (날짜: $DATE)"
done

# 3. 가장 최신 게시물을 가장 마지막에 커밋했기 때문에 git log 최상단에 뜸
echo "🎉 모든 게시물 커밋 완료."
