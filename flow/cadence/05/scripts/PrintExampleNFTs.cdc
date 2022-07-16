import ExampleNFT from "../contracts/ExampleNFT.cdc"

// Print the NFTs owned by account where the contract is deployed
pub fun main(mainAddress: Address) {
    // Get the public account object for deployed account
    let nftOwner = getAccount(mainAddress)

    // Find the public Receiver capability for their Collection
    let capability = nftOwner.getCapability<&{ExampleNFT.NFTReceiver}>(ExampleNFT.CollectionPublicPath)


    // Borrow a reference from the capability
    let receiverRef = capability.borrow() ?? panic("Could not borrow receiver reference")

    // Log the NFTs that they own as an array of IDs
    log("Account ".concat(mainAddress.toString()).concat(" NFTs: "))
    log(receiverRef.getIDs())

}