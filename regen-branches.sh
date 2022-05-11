#!/bin/bash

# 現存するmilestone/**ブランチをAPIで取得

# regex/grepでブランチ名のみを取得、配列に格納

# 配列をループし、既存のmilestone/**ブランチを削除した上、再度作成（feature/master起点）

    # milestoneに紐付いたPRを作成順に取得し、名前/SHA1を配列に格納

    # 配列をループし、PRをmilestoneにマージ
    # Conflict起きたら中断

# stage/dev, stage/cs, stage/qaを削除した上、再度作成

# milestone/**をすべてstage/dev, stage/cs, stage/qaにマージ

