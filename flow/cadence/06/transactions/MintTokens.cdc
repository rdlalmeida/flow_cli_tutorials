import ExampleToken from "../contracts/ExampleToken.cdc"

// This transaction mints tokens and deposits them into account's 3 vault
transaction(recipientAddress: Address, amount: UFix64) {
    // Local variable for storing the reference to the minter resource
    var mintingRef: &ExampleToken.VaultMinter

    /*
        Local variable for storing the reference to the Vault of the account that will receive the newly minted tokens
    */
    var receiver: Capability<&ExampleToken.Vault{ExampleToken.Receiver}>

    prepare(account: AuthAccount) {
        // Borrow a reference to the stored, private minter resource
        self.mintingRef = account.borrow<&ExampleToken.VaultMinter>(from: ExampleToken.VaultMinterStoragePath) ?? panic("Could not borrow a reference to the minter")

        // Get the public account object for the receiver account
        let recipient = getAccount(recipientAddress)

        // Get their public receiver capability
        self.receiver = recipient.getCapability<&ExampleToken.Vault{ExampleToken.Receiver}>(ExampleToken.VaultPublicPath)
    }

    execute {
        // Mint 30 tokens and deposit them into the the recipient's Vault
        self.mintingRef.mintTokens(amount: amount, recipient: self.receiver)

        log(amount.toString().concat(" tokens minted and deposited to account ").concat(self.receiver.address.toString()))

    }
}