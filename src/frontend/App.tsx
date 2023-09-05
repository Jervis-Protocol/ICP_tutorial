import React from "react"
import logo from "./assets/dfinity.svg"
/*
 * Connect2ic provides essential utilities for IC app development
 */
import { createClient } from "@connect2ic/core"
import { defaultProviders } from "@connect2ic/core/providers"
import { ConnectButton, ConnectDialog, Connect2ICProvider } from "@connect2ic/react"
import "@connect2ic/core/style.css"
/*
 * Import canister definitions like this:
 */
import * as counter from "./declarations/counter"
/*
 * Some examples to get you started
 */
import { Counter } from "./components/Counter"
import { Transfer } from "./components/Transfer"
import { Profile } from "./components/Profile"

import { AuthClient } from "@dfinity/auth-client"
import { BackendActor }  from './agent';
function App() {
  
  const onConnect = async () => {
    const authClient = await AuthClient.create()
    await authClient.login({
      identityProvider: `http://${process.env.INTERNET_IDENTITY_CANISTER_ID}.localhost:8123/#authorize`,
      onSuccess: () => console.log("Logged in!"),
    });
    const isAuth =  await authClient.isAuthenticated();
    const auth = await BackendActor.setAuthClient(authClient);
    console.log("isAuth: ", isAuth);
    const actor = await BackendActor.getBackendActor();
    console.log("actor: ", actor);
    console.log("Identity: ", BackendActor.getIdentity().getPrincipal().toString());
    console.log("Connected!")
    console.log("identity: ", authClient.getIdentity().getPrincipal().toString());
  }

  return (
    <div className="App">
      <div className="auth-section">
        <button onClick={() => onConnect()}>Connect</button>
      </div>
      <ConnectDialog />

      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p className="slogan">
          React+TypeScript Template
        </p>
        <p className="twitter">by <a href="https://twitter.com/miamaruq">@miamaruq</a></p>
      </header>

      <p className="examples-title">
        Examples
      </p>
      <div className="examples">
        <Counter />
        <Profile />
        <Transfer />
      </div>
    </div>
  )
}

const client = createClient({
  canisters: {
    counter,
  },
  providers: defaultProviders,
  globalProviderConfig: {
    dev: import.meta.env.DEV,
  },
})

export default () => (
  <Connect2ICProvider client={client}>
    <App />
  </Connect2ICProvider>
)
