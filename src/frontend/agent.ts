import { Actor, HttpAgent, ActorSubclass } from '@dfinity/agent';
import { AuthClient } from "@dfinity/auth-client";
import { _SERVICE } from "./declarations/counter/counter.did";
import { createActor, canisterId } from "./declarations/counter";

export namespace BackendActor {
  var authClient: AuthClient;
  var identity: any;
  export async function setAuthClient(ac: AuthClient) {
    authClient = ac;
  }
  export async function getBackendActor(): Promise<ActorSubclass<_SERVICE>> {
    if (!authClient) {
      authClient = await AuthClient.create();
    }
    identity = authClient.getIdentity();
    console.log("identity: ", identity)

    const backendActor = createActor(canisterId as string, {
      agentOptions: {
        identity, 
      }
    });
  
    return backendActor;
  }

  export const getIdentity = () => identity;
};