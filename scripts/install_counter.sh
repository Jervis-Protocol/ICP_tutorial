set -e

dfx generate counter
echo "generated counter"

dfx deploy counter
echo "deployed counter"