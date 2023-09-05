export const idlFactory = ({ IDL }) => {
  const Time = IDL.Int;
  const Principal = IDL.Principal;
  const Funding = IDL.Record({
    'title' : IDL.Text,
    'creator' : Principal,
    'goal' : IDL.Nat,
    'deadLine' : Time,
    'description' : IDL.Text,
    'currentValue' : IDL.Nat,
    'finished' : IDL.Bool,
    'backers' : IDL.Vec(IDL.Principal),
  });
  return IDL.Service({
    'createFunding' : IDL.Func(
        [IDL.Text, IDL.Text, IDL.Nat, Time, IDL.Principal],
        [IDL.Nat],
        [],
      ),
    'fund' : IDL.Func([IDL.Nat, IDL.Nat, IDL.Principal], [IDL.Bool], []),
    'getFunding' : IDL.Func([IDL.Nat], [IDL.Opt(Funding)], ['query']),
    'getHello' : IDL.Func([], [IDL.Text], []),
    'onFinishSchdule' : IDL.Func([], [], []),
    'withdraw' : IDL.Func([IDL.Nat, IDL.Principal], [IDL.Bool], []),
  });
};
export const init = ({ IDL }) => { return []; };
