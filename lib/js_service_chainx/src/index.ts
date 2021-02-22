import "@babel/polyfill"
import { ApiPromise } from "@polkadot/api"
const { WsProvider } = require("@polkadot/rpc-provider")
const { options } = require("@chainx-v2/api")
import { subscribeMessage, getNetworkConst, getNetworkProperties } from "./service/setting"
import keyring from "./service/keyring"
import account from "./service/account"
import staking from "./service/staking"
import wc from "./service/walletconnect"
import gov from "./service/gov"
import { genLinks } from "./utils/config/config"

// send message to JSChannel: PolkaWallet
function send(path: string, data: any) {
  if (window.location.href.match("about:blank")) {
    PolkaWallet.postMessage(JSON.stringify({ path, data }))
  } else {
    console.log(path, data)
  }
}
send("log", "chainx main js loaded")
;(<any>window).send = send

/**
 * connect to a specific node.
 *
 * @param {string} nodeEndpoint
 */
async function connect(nodes: string[]) {
  return new Promise(async (resolve, reject) => {
    const wsProvider = new WsProvider(nodes)
    try {
      const res = await ApiPromise.create(options({ provider: wsProvider }))
      ;(<any>window).api = res
      send("log", res.genesisHash.toHuman())
      await res.isReady
      send("log", `wss connected success`)
      resolve(true)
    } catch (err) {
      send("log", `connect failed`)
      wsProvider.disconnect()
      resolve(null)
    }
  })
}

const test = async () => {
  // const props = await api.rpc.system.properties();
  // send("log", props);
}
;(<any>window).settings = {
  test,
  connect,
  subscribeMessage,
  getNetworkConst,
  getNetworkProperties,
  // generate external links to polkascan/subscan/polkassembly...
  genLinks,
}
;(<any>window).keyring = keyring
;(<any>window).account = account
;(<any>window).staking = staking
;(<any>window).gov = gov
;(<any>window).walletConnect = wc
