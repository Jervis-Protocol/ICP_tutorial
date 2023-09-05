import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Funding {
  'title' : string,
  'creator' : Principal,
  'goal' : bigint,
  'deadLine' : Time,
  'description' : string,
  'currentValue' : bigint,
  'finished' : boolean,
  'backers' : Array<Principal>,
}
export type Principal = Principal;
export type Time = bigint;
export interface _SERVICE {
  'createFunding' : ActorMethod<
    [string, string, bigint, Time, Principal],
    bigint
  >,
  'fund' : ActorMethod<[bigint, bigint, Principal], boolean>,
  'getFunding' : ActorMethod<[bigint], [] | [Funding]>,
  'getHello' : ActorMethod<[], string>,
  'onFinishSchdule' : ActorMethod<[], undefined>,
  'withdraw' : ActorMethod<[bigint, Principal], boolean>,
}
