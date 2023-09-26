import React from "react"
import { createActor, canisterId } from '../declarations/ledger_canister'
import { Principal } from '@dfinity/principal'
import { HttpAgent } from "@dfinity/agent"

const Transfer = (props) => {

  const transfer = async (to: string, amount: number) => {
    await actor.icrc1_transfer({
      to: { owner: Principal.fromText(to), subaccount: [] },
      amount: BigInt(amount*(10**8)),
      fee: [],
      memo: [],
      from_subaccount: [],
      created_at_time: []
    })
  }

  const onSubmit = async (event) => {
    event.preventDefault();
    await transfer(event.target.to.value, event.target.amount.value);
  }

  const agent = new HttpAgent({
    identity: props.identity,
    host: "http://localhost:8122"
  })

  const actor = createActor(canisterId.toString(), {agent});

  return (
    <div className="example">

      {props.connect ? (
        <>
          <form onSubmit={onSubmit}>
            To: <input type="text" name="to" /><br />
            Amount: <input type="text" name="amount" /><br />
            <button type="submit" >Send</button>
          </form>
        </>
      ) : (
        <p className="example-disabled">Connect with a wallet to access this example</p>
      )}
    </div>
  )
}

export { Transfer }
