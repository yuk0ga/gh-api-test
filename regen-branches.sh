#!/bin/bash
# Prerequisites: jq

token=yuk0ga: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
owner=yuk0ga
repo=gh-api-test
master=master

# 現存するmilestone/**ブランチをAPIで取得 (List matching references)し、変数に格納
echo Fetching milestone/\*\* branches...

milestones=$(curl -u $token https://api.github.com/repos/$owner/$repo/git/matching-refs/heads/milestone | jq -r '.[] | .ref' | sed 's/refs\/heads\/milestone\///g')

echo Fetched:
echo $milestones

# \nを,に変換し(example3)、配列に格納 (ref)
IFS=',' read -a ms_refs <<< "$(echo "$milestones" | sed 'H;1h;$!d;x;y/\n/,/')"

# feature/masterのSHA1 hashを取得
echo Fetching commit revision hash for $master...

master_sha1=$(curl -u $token https://api.github.com/repos/$owner/$repo/git/refs/heads/$master | jq -r '.object.sha')

echo Fetched: $master_sha1

# milestoneの名前の配列をループし、
for m in "${ms_refs[@]}"
do
    # 既存のmilestone/**ブランチを削除した上、再度作成（feature/master起点）
  echo Deleting branch milestone/$m from $owner/$repo...
    curl -u $token \
  -X DELETE \
 https://api.github.com/repos/$owner/$repo/git/refs/heads/milestone/$m
  echo Branch deleted
  echo Recreating branch milestone/$m in $owner/$repo... based on $master...
  curl -u $token \
  -X POST \
  https://api.github.com/repos/$owner/$repo/git/refs \
  -d '{"ref":"refs/heads/milestone/'$m'","sha":"'$master_sha1'"}'
  echo Branch created

   # milestoneに紐付いたPRを作成順に取得し、名前(/SHA1)PRのURLを配列に格納
  echo Fetching PRs attached to milestone: $m...
  prs=$(curl -u $token https://api.github.com/search/issues\?q\=milestone:$m+repo:$owner/$repo\&sort=created\&order=asc | jq -r '.items[] | .pull_request.url')
  echo Fetched:
  echo $prs

    # \nを,に変換し(example3)、配列に格納 (ref)
  IFS=',' read -a pr_urls <<< "$(echo "$prs" | sed 'H;1h;$!d;x;y/\n/,/')"

  # PR URLの配列をループし、PRをmilestoneにマージ
    # Conflict起きたら中断
  echo Merging all PRs to milestone/$m...
  echo ${#pr_urls[@]}
  for p in “${pr_urls[@]}”
  do
    echo Merging $p...
    curl -f -u $token \
         -X PUT \
         "${p}/merge"
    echo Merged
  done
done


