import { LaminarApi } from "@laminar/api";

async function subscribeMessage(laminarApi: LaminarApi, section: string, method: string, params: any[], msgChannel: string) {
  const s = laminarApi[section][method](...params).subscribe((data: any) => {
    (<any>window).send(msgChannel, data);
  });
  const unsubFuncName = `unsub${msgChannel}`;
  window[unsubFuncName] = s.unsubscribe;
  return {};
}

async function subscribeSyntheticPools(laminarApi: LaminarApi, msgChannelSyntheticPools: string) {
  laminarApi.synthetic.allPoolIds().subscribe((ids: any) => {
    ids.forEach((id: any) => {
      laminarApi.synthetic.poolInfo(id).subscribe((res: any) => {
        res.options.forEach((e: any) => (e.poolId = res.poolId));
        (<any>window).send(msgChannelSyntheticPools, res);
      });
    });
  });
  return {};
}

async function subscribeMarginPools(laminarApi: LaminarApi, msgChannelMarginPools: string) {
  laminarApi.margin.allPoolIds().subscribe((ids: any) => {
    ids.forEach((id: any) => {
      laminarApi.margin.poolInfo(id).subscribe((res: any) => {
        res.options.forEach((e) => (e.poolId = res.poolId));
        (<any>window).send(msgChannelMarginPools, res);
      });
    });
  });
  return {};
}

async function subscribeMarginTraderInfo(laminarApi: LaminarApi, address: string, msgChannelMarginTraderInfo: string) {
  laminarApi.margin.allPoolIds().subscribe((ids: any) => {
    ids.forEach((id: any) => {
      laminarApi.margin.traderInfo(address, id).subscribe((res: any) => {
        res.poolId = id;
        (<any>window).send(msgChannelMarginTraderInfo, res);
      });
    });
  });
  return {};
}

export default {
  subscribeMessage,
  subscribeSyntheticPools,
  subscribeMarginPools,
  subscribeMarginTraderInfo,
};
