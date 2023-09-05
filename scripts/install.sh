set -e
dfx stop && dfx start --background --clean --host 127.0.0.1:8123
rm -rf ../src/frontend/dist || true

### === DEPLOY LOCAL LEDGER =====
dfx identity new minter --disable-encryption || true
dfx identity use minter
export MINT_ACC=$(dfx ledger account-id)

dfx identity use default
export LEDGER_ACC=$(dfx ledger account-id)

# Use private api for install
rm src/ledger/ledger.did || true
cp src/ledger/ledger.private.did src/ledger/ledger.did

dfx deploy ledger --argument '(record  {
    minting_account = "'${MINT_ACC}'";
    initial_values = vec { record { "'${LEDGER_ACC}'"; record { e8s=100_000_000_000 } }; };
    send_whitelist = vec {}
    })'
export LEDGER_ID=$(dfx canister id ledger)

# Replace with public api
rm src/ledger/ledger.did
cp src/ledger/ledger.public.did src/ledger/ledger.did
### === DEPLOY INTERNET IDENTITY =====

II_FETCH_ROOT_KEY=1 dfx deploy internet_identity --no-wallet --argument '(null)'

## === INSTALL FRONTEND / BACKEND ==== 

dfx generate ledger
echo "generated ledger"

dfx deploy ledger
echo "deployed ledger"

dfx deploy keedari 
echo "deployed keedari"

dfx generate keedari
echo "generated keedari"

dfx build keedari
echo "built keedari"

dfx generate keedari
echo "generated keedari"

dfx generate counter
echo "generated counter"

dfx deploy counter
echo "deployed counter"


dfx canister create frontend
echo "created frontend"
pushd src/frontend
echo "pushsh frontend"
npm install
echo "installed frontend"
npm run build
echo "built frontend"
popd
echo "popd frontend"
dfx build frontend
echo "built frontend"
dfx canister install frontend
echo "installed frontend"

# echo "===== VISIT DEFI FRONTEND ====="
echo "http://127.0.0.1:8123?canisterId=$(dfx canister id frontend)"
# echo "===== VISIT D.EFI FRONTEND ====="
