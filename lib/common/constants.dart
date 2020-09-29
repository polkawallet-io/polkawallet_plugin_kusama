import 'package:flutter/material.dart';

const node_list_kusama = [
  {
    'name': 'Kusama (Polkadot Canary, hosted by Polkawallet)',
    'ss58': 2,
    'endpoint': 'wss://kusama-1.polkawallet.io:9944/',
  },
  {
    'name': 'Kusama (Polkadot Canary, hosted by Polkawallet Asia)',
    'ss58': 2,
    'endpoint': 'wss://kusama-2.polkawallet.io/',
  },
  {
    'name': 'Kusama (Polkadot Canary, hosted by Parity)',
    'ss58': 2,
    'endpoint': 'wss://kusama-rpc.polkadot.io/',
  },
  {
    'name': 'Kusama (Polkadot Canary, hosted by Web3 Foundation)',
    'ss58': 2,
    'endpoint': 'wss://cc3-5.kusama.network/',
  }
];
const node_list_polkadot = [
  {
    'name': 'Polkadot (Live, hosted by Polkawallet CN)',
    'ss58': 0,
    'endpoint': 'wss://polkadot-1.polkawallet.io:9944',
  },
  {
    'name': 'Polkadot (Live, hosted by Polkawallet EU)',
    'ss58': 0,
    'endpoint': 'wss://polkadot-2.polkawallet.io',
  },
  {
    'name': 'Polkadot (Live, hosted by Parity)',
    'ss58': 0,
    'endpoint': 'wss://rpc.polkadot.io',
  },
  {
    'name': 'Polkadot (Live, hosted by Web3 Foundation)',
    'ss58': 0,
    'endpoint': 'wss://cc1-1.polkadot.network',
  }
];

const home_nav_items = ['Staking', 'Governance'];

const MaterialColor kusama_black = const MaterialColor(
  0xFF222222,
  const <int, Color>{
    50: const Color(0xFF555555),
    100: const Color(0xFF444444),
    200: const Color(0xFF444444),
    300: const Color(0xFF333333),
    400: const Color(0xFF333333),
    500: const Color(0xFF222222),
    600: const Color(0xFF111111),
    700: const Color(0xFF111111),
    800: const Color(0xFF000000),
    900: const Color(0xFF000000),
  },
);
