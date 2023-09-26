#!/bin/bash

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
dfx canister install -m upgrade frontend
echo "installed frontend"
# dfx deploy frontend

# echo "===== VISIT DEFI FRONTEND ====="
echo "http://127.0.0.1:8122?canisterId=$(dfx canister id frontend)"
# echo "===== VISIT DEFI FRONTEND ====="