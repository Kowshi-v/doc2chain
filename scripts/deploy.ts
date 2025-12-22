import { ethers } from "ethers"
import fs from "node:fs";
import path from "node:path";
import dotenv from "dotenv";
import { fileURLToPath } from "node:url";
import { metadata } from "./Metadata.js";

dotenv.config({ path: ".env.local" });
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function main() {
    console.log("🚀 Deploying to Sonic...")

    const abi = metadata.abi;
    const bytecode = metadata.bytecode;

    const provider = new ethers.JsonRpcProvider(process.env.RPC_URL as string);
    const wallet = new ethers.Wallet(process.env.PRIVATE_KEY as string, provider)

    const factory = new ethers.ContractFactory(abi, bytecode, wallet);
    const contract = await factory.deploy();

    await contract.waitForDeployment();
    const deployedAddress = await contract.getAddress();

    console.log(`contract deployed to ${deployedAddress}`)

    const updatedConfig = `
    const Network = {
        networks: {
            Sonic: {
                url: "${process.env.RPC_URL}",
                chainId: 14601,
                address: "${deployedAddress}"
            },
        },
    };
    
    export default Network;
    `;

    const filePath = path.resolve(__dirname, "config.ts");
    fs.writeFileSync(filePath, updatedConfig.trim() + "\n");
}

main().then(err => console.log(err))