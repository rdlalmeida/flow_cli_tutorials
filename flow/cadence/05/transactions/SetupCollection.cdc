import ExampleNFT from "../contracts/ExampleNFT.cdc"

/*
    This transacrion configures a user's account to use the NFT contract by creating a new empty collection,
    storing it in their account storage, and publishing a capability
*/

transaction() {
    prepare(account: AuthAccount) {
        // Create a new empty collection
        let collection <- ExampleNFT.createEmptyCollection()

        // Store the empty NFT Collection in account storage
        account.save<@ExampleNFT.Collection>(<- collection, to: ExampleNFT.CollectionStoragePath)

        log("Collection created for account ".concat(account.address.toString()))

        // Create a public capability for the Collection
        account.link<&{ExampleNFT.NFTReceiver}>(ExampleNFT.CollectionPublicPath, target: ExampleNFT.CollectionStoragePath)

        log("Capability created for account ".concat(account.address.toString()))
    }
}