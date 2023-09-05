import { useCanister } from "@connect2ic/react"
import React, { useEffect, useState } from "react"
import { Actor, HttpAgent } from "@dfinity/agent";
import { createActor, canisterId } from "../declarations/counter";
import { BackendActor }  from '../agent';
const Counter = () => {
  /*
  * This how you use canisters throughout your app.
  */
  const [counter] = useCanister("counter")
  const [count, setCount] = useState<bigint>()
  
  const refreshCounter = async () => {
    const freshCount = await counter.getValue() as bigint
    setCount(freshCount)
  }

  const init = () => {
    const options = { agentOptions: { host: "http://localhost:8123" } };
    const agent = new HttpAgent({ ... options.agentOptions });
    agent.fetchRootKey().catch(err => {
      console.warn("Unable to fetch root key. Check to ensure that your local replica is running");
      console.error(err);
    });

    const counterActor = createActor(canisterId, { agent, ...options });
  }

  const increment = async () => {
    const actor = await BackendActor.getBackendActor();
    console.log("Identity: ", BackendActor.getIdentity().getPrincipal().toString());
    console.log("Counter: ", counter);
    console.log("incrementing")
    init();
    await actor.increment();
    console.log("incremented")
    const newCount = await actor.getValue() as bigint;
    setCount(newCount);
    console.log("newCount: ", newCount);

  }

  useEffect(() => {
    if (!counter) {
      return
    }
    refreshCounter()
  }, [counter])

  return (
    <div className="example">
      <p style={{ fontSize: "2.5em" }}>{count?.toString()}</p>
      <button className="connect-button" onClick={() => increment()}>+</button>
    </div>
  )
}

export { Counter }

function useAuthClient() {
  throw new Error("Function not implemented.")
}
