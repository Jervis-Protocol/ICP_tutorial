set -e
dfx stop && dfx start --background --clean --host 127.0.0.1:8122
rm -rf ../src/frontend/dist || true

### === DEPLOY LOCAL LEDGER =====
wget https://download.dfinity.systems/ic/d87954601e4b22972899e9957e800406a0a6b929/canisters/ledger-canister.wasm.gz

dfx identity new minter --disable-encryption || true
dfx identity use minter
export MINT_ACC=$(dfx identity get-principal)
export MINTER_ACCOUNT_ID=$(dfx ledger account-id)

# export ACCOUNT_ID=2d0e897f7e862d2b57d9bc9ea5c65f9a24ac6c074575f47898314b8d6cb0929d
dfx identity use default

export DEFAULT_ACCOUNT_ID=$(dfx ledger account-id)

# Use private api for install

dfx canister create ledger_canister
mkdir -p ".dfx/local/canisters/ledger_canister"
mv ledger-canister.wasm.gz .dfx/local/canisters/ledger_canister/ledger_canister.wasm.gz


II_FETCH_ROOT_KEY=1 dfx deploy internet_identity --no-wallet --argument '(null)'


# ## === INSTALL FRONTEND / BACKEND ==== 



dfx deploy --specified-id ryjl3-tyaaa-aaaaa-aaaba-cai ledger_canister --argument "
  (variant {
    Init = record {
      minting_account = \"$MINTER_ACCOUNT_ID\";
      initial_values = vec {
        record {
          \"$DEFAULT_ACCOUNT_ID\";
          record {
            e8s = 10_000_000_010_000 : nat64;
          };
        };
      };
      send_whitelist = vec {};
      transfer_fee = opt record {
        e8s = 10_000 : nat64;
      };
      token_symbol = opt \"LICP\";
      token_name = opt \"Local ICP\";
    }
  })
"

dfx generate ledger_canister
echo "generated ledger_canister"
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
# echo "built frontend"
dfx canister install frontend
echo "installed frontend"

# echo "===== VISIT DEFI FRONTEND ====="
echo "http://127.0.0.1:8122?canisterId=$(dfx canister id frontend)"
# echo "===== VISIT D.EFI FRONTEND ====="
