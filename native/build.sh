#!/bin/zsh
#
# MacOS Ruby, PostgreSQL, Heroku build script
#
# @author Kazuki Isogai (github.com/isso-719)

# 移行前に確認
echo "*********************************************************"
echo "注意: このスクリプトは MacOS に以下をインストールします。"
echo "  - Homebrew"
echo "  - anyenv"
echo "  - rbenv"
echo "  - Ruby 3.0.0"
echo "  - PostgreSQL"
echo "  - Heroku CLI"
echo "下記の質問に y もしくは N で回答してください。"
echo "*********************************************************"

read -p "実行してもよろしいですか? y: はい, N: いいえ: " IS_AGREE
if [[ "${IS_AGREE}" != "y" ]]; then
    echo "操作を中止します。"
    exit 1
fi

# 管理者パスワード入力の警告
echo "*********************************************************"
echo "注意: このスクリプトは管理者権限が必要です。"
echo "パスワード入力を求められた場合は、入力してください。"
echo "*********************************************************"

# brew install
if [[ -n "$(command -v brew)" ]]; then
    echo "brew found, updating..."
    brew update
else
    echo "brew not found, installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# anyenv install
brew install anyenv
yes | anyenv install --init
cat <<'EOF' >> ~/.zshrc

# anyenv
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"
EOF
source ~/.zshrc

# rbenv install
anyenv install rbenv
source ~/.zshrc

# ruby 3.0.0 install
rbenv install 3.0.0
rbenv global 3.0.0
source ~/.zshrc

# PostgreSQL install
brew install postgresql@14
brew install libpq

# PostgreSQL start
brew services start postgresql@14
cat <<'EOF' >> ~/.zshrc

# PostgreSQL
export PATH="/usr/local/opt/postgresql@14/bin:$PATH"
EOF
source ~/.zshrc

# initdb
initdb /usr/local/var/postgres
brew services restart postgresql@14

# Create database
createdb $(whoami)

bundle config build.pg -- --with-pg-dir=/usr/local/opt/libpq

# Heroku install
brew tap heroku/brew
brew install heroku
source ~/.zshrc

# 再起動
echo "******************************************************************"
echo "全ての操作が完了しました。"
echo "管理者パスワードを入力し、再起動を行ってください。"
echo "******************************************************************"

sudo reboot