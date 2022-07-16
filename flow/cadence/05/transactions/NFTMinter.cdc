import ExampleNFT from "../contracts/ExampleNFT.cdc"

/*
    This transaction allows the Minter account to mint an NFT and deposit it into its collection
*/

transaction() {
    // The reference to the collection that will be receiving the NFT
    let receiverRef: &{ExampleNFT.NFTReceiver}

    prepare(account: AuthAccount) {
        // Get the owner's collection capability and borrow a reference
        self.receiverRef = account.getCapability<&{ExampleNFT.NFTReceiver}>(ExampleNFT.CollectionPublicPath).borrow()
            ?? panic("Could not find a valid collection in ".concat(ExampleNFT.CollectionPublicPath.toString()))
    }

    execute {
        // Use the minter reference to mint an NFT, which deposits the NFT into the collections that is sent as a parameter
        let newNFT <- ExampleNFT.mintNFT()

        self.receiverRef.deposit(token: <- newNFT)

        log("NFT Minted and deposited to Account 1's Collection")
    }
}