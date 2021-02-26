export interface boundedChunks {
  lockedUntil: string
  value: string
}

export interface Nomination {
  validatorId: string
  account: string
  nomination: string
  lastVoteWeight: string
  lastVoteWeightUpdate: string
  unbondedChunks: boundedChunks[]
}

export interface Dividended {
  validator: string
  interest: string
}

export interface UserInterest {
  account: string
  interests: Dividended[]
}
