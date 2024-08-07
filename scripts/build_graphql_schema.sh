curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install node

cat > package.json <<EOF
PKG_JSON_CONTENTS
EOF

npm install

cat > schema_builder.js <<EOF
JS_CONTENTS
EOF

rm -rf *.graphql

GRAPHQL_CONTENTS

node schema_builder.js

cat <<EOF
{
  "res": "test"
}
EOF