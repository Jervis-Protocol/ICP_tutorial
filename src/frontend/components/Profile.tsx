import React, { useEffect, useState, useRef } from "react"
import { ledger_canister } from '../declarations/ledger_canister'
import { Principal } from '@dfinity/principal'

const Profile = (props: any) => {

  const [balance, setBalance] = useState(0);

  const getBalance = async (principal: string) => {
    if (props.address !== "") {
      const bal = await ledger_canister.icrc1_balance_of({ owner: Principal.fromText(principal), subaccount: [] });
      setBalance(Number((Number(bal)/(10**8)).toFixed(4)))
    };
  }

  useEffect(() => {
    const interval = setInterval(() => getBalance(props.address), 1000);
    return () => clearInterval(interval)
  })

  return (
    <div className="example">
      {props.connect ? (
        <>
          <div>Principal: </div>
          <div><span style={{ fontSize: "1em" }}>{props.address}</span></div>
          <p>Balance: <span style={{ fontSize: "1em" }}>{balance} ICP</span></p>
        </>
      ) : (
        <p className="example-disabled">Connect with a wallet to access this example</p>
      )}
    </div>
  )
}

export { Profile }
