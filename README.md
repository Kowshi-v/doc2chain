# DoctrChain

### configure sinic chain
- open this https://testnet.soniclabs.com/account
- click on add to wallet button, which you can find on scrolling

### getting sonic tokens
- go to faucet section of this same link and get this sonic token
<img width="1326" height="304" alt="Image" src="https://github.com/user-attachments/assets/72f0f673-aa8b-4d3d-955d-621e3809e77f" />

### configure private key
Open Metamask
- open it in **full screen** from the hamburger menu in rightside top
- then again click the hamburger menu in full screen mode check for **account details**
- search for private key, we are using sonic so copy the private key from sonic network

### configure project
Open .env.local which is in root, or create it
```file
doc/
├─ artifacts/
│  ├─ build-info/
│  │  ├─ solc-0_8_28-56529869996f74a3f42c338f829d95dbfe8524eb.json
│  │  └─ solc-0_8_28-56529869996f74a3f42c338f829d95dbfe8524eb.output.json
│  ├─ contracts/
│  │  └─ medicalRecord.sol/
│  │     ├─ artifacts.d.ts
│  │     └─ MedicalRecords.json
│  └─ artifacts.d.ts
├─ cache/
│  ├─ build-info/
│  └─ compile-cache.json
├─ contracts/
│  └─ medicalRecord.sol
├─ scripts/
│  ├─ config.ts
│  ├─ deploy.ts
│  └─ Metadata.ts
├─ types/
│  └─ ethers-contracts/
│     ├─ factories/
│     │  ├─ index.ts
│     │  └─ MedicalRecords__factory.ts
│     ├─ common.ts
│     ├─ hardhat.d.ts
│     ├─ index.ts
│     └─ MedicalRecords.ts
├─ .env.local
├─ .gitignore
├─ hardhat.config.ts
├─ package.json
├─ pnpm-lock.yaml
├─ README.md
└─ tsconfig.json
```

add this to your env if you create it if its already present there just add private_key
```env
RPC_URL=https://rpc.testnet.soniclabs.com/
PRIVATE_KEY=ADD_YOUR_PRIVATE_KEY
```

### How to Deploy contract to Sonic
- Just open terminal **ctrl + shift + `**
- pnpm run deploy
- check scripts/config.ts for your contract address
```ts
const Network = {
        networks: {
            Sonic: {
                url: "https://rpc.testnet.soniclabs.com/",
                chainId: 14601,
                address: "ADDRESS"
            },
        },
    };
    
    export default Network;
```

### verify deployment
- open https://testnet.sonicscan.org/address/0xA6D85F4426a6e8B01d5527AD942464Bece8a6bB9
- copy the contract address from config.ts
- paste it in the search bar there and search
- the result should be something like this
<img width="1351" height="597" alt="Image" src="https://github.com/user-attachments/assets/758bb8a9-f9a1-497e-87ce-49cdc062e7c4" />

- should not be something like
```
Your search 0xA6D85F4426a6e8B01d5527AD942464Bece8a6bB - did not match any records.

Suggestions:
Make sure that all words are spelled correctly.
Try different keywords.
Try more general keywords.
```