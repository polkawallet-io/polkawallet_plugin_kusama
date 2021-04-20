import { cryptoWaitReady } from "@polkadot/util-crypto"
import { hexToU8a, u8aToHex, hexToString } from "@polkadot/util"
// @ts-ignore
import { ss58Decode } from "oo7-substrate/src/ss58"
import { polkadotIcon } from "@polkadot/ui-shared"

import { Keyring } from "@polkadot/keyring"
import { ApiPromise } from "@polkadot/api"

import { subscribeMessage } from "./setting"
let keyring = new Keyring({ ss58Format: 44, type: "sr25519" })

/**
 * Get svg icons of addresses.
 */
async function genIcons(addresses: string[]) {
  return addresses.map((i) => {
    const circles = polkadotIcon(i, { isAlternative: false })
      .map(({ cx, cy, fill, r }) => `<circle cx='${cx}' cy='${cy}' fill='${fill}' r='${r}' />`)
      .join("")
    return [i, `<svg viewBox='0 0 64 64' xmlns='http://www.w3.org/2000/svg'>${circles}</svg>`]
  })
}

/**
 * Get svg icons of pubKeys.
 */
async function genPubKeyIcons(pubKeys: string[]) {
  const icons = await genIcons(pubKeys.map((key) => keyring.encodeAddress(hexToU8a(key), 44)))
  return icons.map((i, index) => {
    i[0] = pubKeys[index]
    return i
  })
}

/**
 * decode address to it's publicKey
 */
async function decodeAddress(addresses: string[]) {
  await cryptoWaitReady()
  try {
    const res = {}
    addresses.forEach((i) => {
      const pubKey = u8aToHex(keyring.decodeAddress(i))
      ;(<any>res)[pubKey] = i
    })
    return res
  } catch (err) {
    ;(<any>window).send("log", { error: err.message })
    return null
  }
}

/**
 * encode pubKey to addresses with different prefixes
 */
async function encodeAddress(pubKeys: string[], _ss58Formats: number[]) {
  const ss58Formats = _ss58Formats.includes(44) ? _ss58Formats : [..._ss58Formats, 44]
  await cryptoWaitReady()
  const res = {}
  ss58Formats.forEach((ss58) => {
    ;(<any>res)[ss58] = {}
    pubKeys.forEach((i) => {
      ;(<any>res)[ss58][i] = keyring.encodeAddress(hexToU8a(i), ss58)
    })
  })
  return res
}

/**
 * query account address with account index
 */
async function queryAddressWithAccountIndex(api: ApiPromise, accIndex: string, ss58: number) {
  const num = ss58Decode(accIndex, ss58).toJSON()
  const res = await api.query.indices.accounts(num.data)
  return res
}

/**
 * get staking stash/controller relationship of accounts
 */
async function queryAccountsBonded(api: ApiPromise, pubKeys: string[]) {
  console.log("queryAccountsBonded", api.query)
  return Promise.all(pubKeys.map((key) => keyring.encodeAddress(hexToU8a(key), 44)).map((i) => Promise.all([api.query.staking.bonded(i), api.query.staking.ledger(i)]))).then((ls) =>
    ls.map((i, index) => [pubKeys[index], i[0], i[1].toHuman() ? i[1].toHuman()["stash"] : null])
  )
}

/**
 * get network native token balance of an address
 */
async function getBalance(api: ApiPromise, address: string, msgChannel: string) {
  const transfrom = (res: any) => {
    const lockedBreakdown = res.lockedBreakdown.map((i: any) => {
      return {
        ...i,
        use: hexToString(i.id.toHex()),
      }
    })
    return {
      ...res,
      lockedBreakdown,
    }
  }
  if (msgChannel) {
    subscribeMessage(api.derive.balances.all, [address], msgChannel, transfrom)
    return
  }

  const res = await api.derive.balances.all(address)
  return transfrom(res)
  // let accInfo = await api.query.system.account(address)
  // let accountId = await (await api.derive.balances.account(address)).accountId

  // const transform = (res) => {
  //   return {
  //     accountId: accountId,
  //     accountNonce: res.nonce,
  //     availableBalance: res.data.free,
  //     freeBalance: res.data.free,
  //     reserved: res.data.reserved,
  //   }
  // }

  // /*
  // Balance     8,012.2985194 PCX
  // Reserved    10 PCX
  // Locked      8,000 PCX

  // res.data = {
  //   free: 8.0022 kPCX,
  //   reserved: 10.0000 PCX,
  //   feeFrozen: 8.0000 kPCX
  // }
  // */

  // if (msgChannel) {
  //   subscribeMessage(api.query.system.account, [address], msgChannel, transform)
  //   return
  // }
  // return transform(accInfo)
}

/**
 * get humen info of addresses
 */
async function getAccountIndex(api: ApiPromise, addresses: string[]) {
  return api.derive.accounts.indexes().then(async (res) => {
    const accInfos = await Promise.all(addresses.map((i) => api.derive.accounts.info(i)));
    const validatorInfos = await Promise.all(addresses.map((i) => api.query.xStaking.validators(i)));

    return addresses.map((_, i) => ({ ...accInfos[i], referralId: validatorInfos[i] ? validatorInfos[i].referralId : null }));
  })
}

export default {
  encodeAddress,
  decodeAddress,
  queryAddressWithAccountIndex,
  genIcons,
  genPubKeyIcons,
  queryAccountsBonded,
  getBalance,
  getAccountIndex,
}
